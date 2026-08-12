require "rails_helper"

RSpec.describe WorkspaceBroadcaster do
  it "broadcasts delivery updates to the workspace stream" do
    w = Workspace.create!
    e = w.webhook_endpoints.create!(url: "https://x.co/h", events: %w[hard_bounce])
    ev = w.webhook_events.create!(event_type: "hard_bounce", occurred_at: Time.current, payload: { "recipient" => "a@b.c" })
    d = w.webhook_deliveries.create!(webhook_endpoint: e, webhook_event: ev)
    expect { described_class.delivery_updated(d) }
      .to have_broadcasted_to(WorkspaceChannel.broadcasting_for(w))
      .with(a_hash_including("type" => "delivery.updated"))
  end
end
