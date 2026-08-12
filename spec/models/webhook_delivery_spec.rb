require "rails_helper"

RSpec.describe WebhookDelivery do
  it "starts pending with zero attempts" do
    w = Workspace.create!
    e = w.webhook_endpoints.create!(url: "https://example.com/h", events: %w[hard_bounce])
    ev = w.webhook_events.create!(event_type: "hard_bounce", payload: { "a" => 1 }, occurred_at: Time.current)
    d = w.webhook_deliveries.create!(webhook_endpoint: e, webhook_event: ev)
    expect(d.status).to eq("pending")
    expect(d.attempts_count).to eq(0)
  end
end
