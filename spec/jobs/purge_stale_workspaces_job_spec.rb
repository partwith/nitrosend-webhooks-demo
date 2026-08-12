require "rails_helper"

RSpec.describe PurgeStaleWorkspacesJob do
  it "destroys workspaces idle for more than 24 hours, keeps active ones" do
    stale = Workspace.create!(last_seen_at: 25.hours.ago)
    fresh = Workspace.create!(last_seen_at: 1.hour.ago)
    described_class.perform_now
    expect(Workspace.exists?(stale.id)).to be false
    expect(Workspace.exists?(fresh.id)).to be true
  end
end
