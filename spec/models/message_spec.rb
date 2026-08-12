require "rails_helper"

RSpec.describe Message do
  let(:workspace) { Workspace.create! }

  it "generates a message_id and defaults to accepted" do
    m = workspace.messages.create!(recipient: "a@b.co", subject: "Hi")
    expect(m.message_id).to match(/\Amsg_[a-z0-9]{20}\z/)
    expect(m.status).to eq("accepted")
  end
end
