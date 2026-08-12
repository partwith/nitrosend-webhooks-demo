require "rails_helper"

RSpec.describe WorkspaceChannel do
  it "streams for the connected workspace" do
    w = Workspace.create!
    stub_connection current_workspace: w
    subscribe
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_for(w)
  end
end
