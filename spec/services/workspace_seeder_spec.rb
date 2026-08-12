require "rails_helper"

RSpec.describe WorkspaceSeeder do
  it "seeds bookings and one internal endpoint" do
    w = Workspace.create!
    described_class.seed(w, base_url: "http://demo.test")
    expect(w.bookings.count).to eq(4)
    endpoint = w.webhook_endpoints.sole
    expect(endpoint.url).to eq("http://demo.test/wtm/webhooks/#{w.token}")
    expect(endpoint.events).to match_array(%w[hard_bounce soft_bounce complaint])
  end
end
