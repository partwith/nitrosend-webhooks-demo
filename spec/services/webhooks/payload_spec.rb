require "rails_helper"

RSpec.describe Webhooks::Payload do
  it "builds the documented payload shape" do
    w = Workspace.create!
    m = w.messages.create!(recipient: "bounce@simulator.demo", subject: "Hi")
    ev = w.webhook_events.create!(
      event_type: "hard_bounce", message: m, occurred_at: Time.current,
      payload: {}
    )
    p = described_class.for(ev)
    expect(p.keys).to match_array(%w[event_id event_type occurred_at message_id recipient reason data])
    expect(p["event_id"]).to eq("evt_#{ev.id}")
    expect(p["message_id"]).to eq(m.message_id)
    expect(p["reason"]).to eq("550 5.1.1 user unknown")
    expect(p["data"]["bounce_type"]).to eq("Permanent")
  end
end
