class WebhookDeliveryJob < ApplicationJob
  RETRY_SCHEDULE = [ 30.seconds, 2.minutes, 10.minutes, 30.minutes ].freeze
  MAX_ATTEMPTS = 5
  EXCERPT_LIMIT = 1000

  def perform(delivery_id)
    delivery = WebhookDelivery.find_by(id: delivery_id)
    return unless delivery

    endpoint = nil
    guard = nil
    number = nil
    send_it = false

    # Lock the delivery row just long enough to validate status and reserve
    # the next attempt number, so a re-picked-up duplicate execution of this
    # job (e.g. after a crashed/timed-out run) serializes behind us and
    # reserves the *next* number instead of racing us for this one. Re-check
    # status/attempts_count against the freshly locked row rather than any
    # pre-lock read, since a concurrent execution may have already completed
    # this attempt while we were waiting for the lock.
    #
    # Deliberately released before the outbound HTTP call below: this demo's
    # webhook receiver is often the same running app, so holding a DB
    # transaction open across a slow (or hanging) outbound request risks
    # starving the very request thread that's supposed to receive it.
    delivery.with_lock do
      return unless %w[pending retrying].include?(delivery.status)

      endpoint = delivery.webhook_endpoint
      guard = Webhooks::UrlGuard.check(endpoint.url)
      number = delivery.attempts_count + 1

      if guard.ok?
        delivery.update!(attempts_count: number)
        send_it = true
      else
        delivery.delivery_attempts.create!(number:, error: "URL #{guard.error}")
        delivery.update!(status: "failed", attempts_count: number, next_retry_at: nil)
      end
    end

    attempt_http(delivery, endpoint, guard, number) if send_it
    WorkspaceBroadcaster.delivery_updated(delivery.reload)
  end

  private

  def attempt_http(delivery, endpoint, guard, number)
    body = delivery.webhook_event.payload.to_json
    timestamp = Time.current.to_i
    headers = {
      "Content-Type" => "application/json",
      "User-Agent" => "Nitrosend-Webhooks-Demo/1.0",
      "X-Nitrosend-Event" => delivery.webhook_event.event_type,
      "X-Nitrosend-Timestamp" => timestamp.to_s,
      "X-Nitrosend-Signature" => Webhooks::Signer.signature(secret: endpoint.signing_secret, timestamp:, body:)
    }

    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    response = post(guard, headers, body)
    latency_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round

    record_result(delivery, number, response, headers, latency_ms)
  end

  def record_result(delivery, number, response, headers, latency_ms)
    delivery.with_lock do
      begin
        # A nested transaction (Postgres savepoint) so a rescued unique
        # violation only rolls back this insert, not the whole locked
        # transaction.
        delivery.transaction(requires_new: true) do
          delivery.delivery_attempts.create!(
            number:, request_headers: headers, latency_ms:,
            http_status: response.is_a?(Net::HTTPResponse) ? response.code.to_i : nil,
            response_excerpt: response.is_a?(Net::HTTPResponse) ? response.body.to_s.first(EXCERPT_LIMIT) : nil,
            error: response.is_a?(String) ? response : nil,
          )
        end
      rescue ActiveRecord::RecordNotUnique
        # The attempt number we reserved was already recorded — a concurrent
        # duplicate execution of this job beat us to it (the reservation in
        # #perform should make this unreachable in practice; the unique
        # index on [webhook_delivery_id, number] is the hard backstop).
        # Nothing left for us to record.
        return
      end

      # The reservation lock in #perform is released before the outbound HTTP
      # call, so two concurrent executions of the same job can both reserve a
      # number and both send. That's a real, known residual risk (a slow
      # loser making a genuine duplicate delivery) that this class does not
      # fully close without reintroducing the deadlock the reservation split
      # was built to avoid — see the comment in #perform.
      #
      # What this check DOES close: a slow loser overwriting a newer,
      # already-terminal outcome. Without it, a late-arriving failure for an
      # earlier attempt number could regress a delivery a *later* attempt had
      # already marked "delivered" back to "retrying" — silently scheduling
      # a third, spurious delivery to an endpoint that already succeeded.
      # Skip finalizing if a later attempt already recorded a result, or if
      # the delivery already reached a terminal state.
      return if delivery.attempts_count > number || %w[delivered failed].include?(delivery.status)

      if response.is_a?(Net::HTTPResponse) && response.code.to_i.between?(200, 299)
        delivery.update!(status: "delivered", attempts_count: number, next_retry_at: nil)
      elsif number >= MAX_ATTEMPTS
        delivery.update!(status: "failed", attempts_count: number, next_retry_at: nil)
      else
        wait = RETRY_SCHEDULE[number - 1]
        delivery.update!(status: "retrying", attempts_count: number, next_retry_at: wait.from_now)
        self.class.set(wait:).perform_later(delivery.id)
      end
    end
  end

  # Returns Net::HTTPResponse on any HTTP response, String error message otherwise.
  def post(guard, headers, body)
    uri = guard.uri
    Net::HTTP.start(uri.host, uri.port, ipaddr: guard.ip, use_ssl: uri.scheme == "https",
                    open_timeout: 5, read_timeout: 5, write_timeout: 5) do |http|
      http.request_post(uri.request_uri, body, headers)
    end
  rescue StandardError => e
    "#{e.class}: #{e.message}".first(200)
  end
end
