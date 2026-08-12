class WebhookDelivery < ApplicationRecord
  STATUSES = %w[pending delivering delivered retrying failed].freeze
  belongs_to :workspace
  belongs_to :webhook_endpoint
  belongs_to :webhook_event
  has_many :delivery_attempts, -> { order(:number) }, dependent: :destroy
  validates :status, inclusion: { in: STATUSES }

  def as_api_json(full: false)
    last = delivery_attempts.last
    base = {
      id:, endpoint_id: webhook_endpoint_id, status:, attempts_count:, next_retry_at:, created_at:,
      event: { event_type: webhook_event.event_type, recipient: webhook_event.payload["recipient"], payload: webhook_event.payload },
      last_attempt: last && { http_status: last.http_status, latency_ms: last.latency_ms, error: last.error, created_at: last.created_at },
    }
    full ? base.merge(attempts: delivery_attempts.map { |a| a.as_json(only: %i[number http_status response_excerpt latency_ms error request_headers created_at]) }) : base
  end
end
