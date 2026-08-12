require "rails_helper"

RSpec.describe Message do
  let(:workspace) { Workspace.create! }

  it "generates a message_id and defaults to accepted" do
    m = workspace.messages.create!(recipient: "a@b.co", subject: "Hi")
    expect(m.message_id).to match(/\Amsg_[a-z0-9]{20}\z/)
    expect(m.status).to eq("accepted")
  end

  it "nullifies dependent webhook_events instead of blocking on their foreign key" do
    message = workspace.messages.create!(recipient: "bounce@simulator.demo", subject: "Hi")
    event = workspace.webhook_events.create!(event_type: "hard_bounce", message:, occurred_at: Time.current, payload: {})

    expect { message.destroy! }.not_to raise_error

    expect(Message.exists?(message.id)).to be false
    expect(event.reload.message_id).to be_nil
  end
end
