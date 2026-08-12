require "rails_helper"

RSpec.describe "Workspace cookie" do
  it "creates a workspace on first visit and reuses it" do
    get "/"
    expect(Workspace.count).to eq(1)
    get "/"
    expect(Workspace.count).to eq(1)
  end

  it "issues a fresh workspace when the cookie is stale" do
    get "/"
    Workspace.first.destroy!
    get "/"
    expect(Workspace.count).to eq(1)
  end
end
