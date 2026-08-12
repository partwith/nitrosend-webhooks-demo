require "rails_helper"

RSpec.describe SimulateSesJob do
  let(:workspace) { Workspace.create! }
  let!(:endpoint) { workspace.webhook_endpoints.create!(url: "https://x.co/h", events: %w[hard_bounce complaint]) }

  def run_for(recipient)
    message = workspace.messages.create!(recipient:, subject: "Hi")
    described_class.perform_now(message.id)
    message.reload
  end

  it "hard-bounces the magic address, suppresses, fans out" do
    expect { run_for("bounce@simulator.demo") }
      .to change { workspace.suppressions.count }.by(1)
      .and change { workspace.webhook_deliveries.count }.by(1)
      .and have_enqueued_job(WebhookDeliveryJob)
    expect(workspace.messages.last.status).to eq("bounced")
    expect(workspace.webhook_events.sole.event_type).to eq("hard_bounce")
  end

  it "soft-bounces without suppressing (endpoint not subscribed → no delivery)" do
    m = run_for("softbounce@simulator.demo")
    expect(m.status).to eq("bounced")
    expect(workspace.suppressions.count).to eq(0)
    expect(workspace.webhook_deliveries.count).to eq(0)
  end

  it "delivers normal addresses with no event" do
    m = run_for("maya@example.com")
    expect(m.status).to eq("delivered")
    expect(workspace.webhook_events.count).to eq(0)
  end

  it "records complaints" do
    m = run_for("complaint@simulator.demo")
    expect(m.status).to eq("complained")
    expect(workspace.suppressions.sole.reason).to eq("abuse")
  end
end
