class SimulateSesJob < ApplicationJob
  ROUTES = {
    "bounce@simulator.demo" => "hard_bounce",
    "softbounce@simulator.demo" => "soft_bounce",
    "complaint@simulator.demo" => "complaint",
  }.freeze

  def perform(message_db_id)
    message = Message.find_by(id: message_db_id)
    return unless message&.status == "accepted"

    event_type = ROUTES[message.recipient.downcase]
    return message.update!(status: "delivered") unless event_type

    workspace = message.workspace
    message.update!(status: event_type == "complaint" ? "complained" : "bounced",
                    status_reason: Webhooks::Payload::DETAILS.fetch(event_type)[:reason])
    WorkspaceBroadcaster.message_updated(message)

    if %w[hard_bounce complaint].include?(event_type)
      workspace.suppressions.create_or_find_by!(email: message.recipient) do |s|
        s.reason = Webhooks::Payload::DETAILS.fetch(event_type)[:reason]
        s.event_type = event_type
      end
    end
    WorkspaceBroadcaster.booking_updated(message.booking.reload) if message.booking

    event = workspace.webhook_events.create!(event_type:, message:, occurred_at: Time.current, payload: {})
    event.update!(payload: Webhooks::Payload.for(event))

    workspace.webhook_endpoints.select { |e| e.subscribed_to?(event_type) }.each do |endpoint|
      delivery = workspace.webhook_deliveries.create!(webhook_endpoint: endpoint, webhook_event: event)
      WebhookDeliveryJob.perform_later(delivery.id)
    end
  end
end
