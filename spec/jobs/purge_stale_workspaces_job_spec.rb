require "rails_helper"

RSpec.describe PurgeStaleWorkspacesJob do
  it "destroys workspaces idle for more than 24 hours, keeps active ones" do
    stale = Workspace.create!(last_seen_at: 25.hours.ago)
    fresh = Workspace.create!(last_seen_at: 1.hour.ago)
    described_class.perform_now
    expect(Workspace.exists?(stale.id)).to be false
    expect(Workspace.exists?(fresh.id)).to be true
  end

  it "purges a stale workspace with a full graph of webhook activity without raising" do
    workspace = Workspace.create!(last_seen_at: 25.hours.ago)
    booking = workspace.bookings.create!(learner_name: "Ada", email: "ada@example.com")
    message = workspace.messages.create!(recipient: "bounce@simulator.demo", subject: "Hi", booking:)
    suppression = workspace.suppressions.create!(email: "ada@example.com")
    endpoint = workspace.webhook_endpoints.create!(url: "https://hooks.example.com/wh", events: %w[hard_bounce])
    event = workspace.webhook_events.create!(event_type: "hard_bounce", message:, occurred_at: Time.current, payload: {})
    delivery = workspace.webhook_deliveries.create!(webhook_endpoint: endpoint, webhook_event: event)
    attempt = delivery.delivery_attempts.create!(number: 1, http_status: 500)

    expect { described_class.perform_now }.not_to raise_error

    expect(Workspace.exists?(workspace.id)).to be false
    expect(Booking.exists?(booking.id)).to be false
    expect(Message.exists?(message.id)).to be false
    expect(Suppression.exists?(suppression.id)).to be false
    expect(WebhookEndpoint.exists?(endpoint.id)).to be false
    expect(WebhookDelivery.exists?(delivery.id)).to be false
    expect(DeliveryAttempt.exists?(attempt.id)).to be false

    # The event is destroyed too (Workspace has its own dependent: :destroy on
    # webhook_events) — what this regression guards is the destroy *order*:
    # without Message#webhook_events (dependent: :nullify), Workspace destroying
    # messages before webhook_events would hit a live FK violation and abort
    # the whole cascade before it got this far.
    expect(WebhookEvent.exists?(event.id)).to be false
  end
end
