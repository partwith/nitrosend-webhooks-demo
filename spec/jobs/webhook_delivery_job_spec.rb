require "rails_helper"

RSpec.describe WebhookDeliveryJob do
  let(:workspace) { Workspace.create! }
  let(:endpoint) { workspace.webhook_endpoints.create!(url: "https://hooks.example.com/wh", events: %w[hard_bounce]) }
  let(:message) { workspace.messages.create!(recipient: "bounce@simulator.demo", subject: "Hi") }
  let(:event) do
    ev = workspace.webhook_events.create!(event_type: "hard_bounce", message:, occurred_at: Time.current, payload: {})
    ev.update!(payload: Webhooks::Payload.for(ev)); ev
  end
  let(:delivery) { workspace.webhook_deliveries.create!(webhook_endpoint: endpoint, webhook_event: event) }

  before { allow(Resolv).to receive(:getaddress).and_return("93.184.216.34") }

  it "delivers on 200, recording a signed attempt" do
    stub = stub_request(:post, "https://hooks.example.com/wh").to_return(status: 200, body: "ok")
    described_class.perform_now(delivery.id)
    expect(delivery.reload.status).to eq("delivered")
    attempt = delivery.delivery_attempts.sole
    expect(attempt.http_status).to eq(200)
    ts = attempt.request_headers.fetch("X-Nitrosend-Timestamp")
    # Compare against the payload as actually persisted (jsonb reorders keys on
    # round-trip, and the job re-queries the delivery/event fresh from the DB).
    expect(attempt.request_headers.fetch("X-Nitrosend-Signature"))
      .to eq(Webhooks::Signer.signature(secret: endpoint.signing_secret, timestamp: ts, body: event.reload.payload.to_json))
    expect(stub).to have_been_requested
  end

  it "schedules a retry on 500 with the first backoff step" do
    stub_request(:post, "https://hooks.example.com/wh").to_return(status: 500, body: "boom")
    expect { described_class.perform_now(delivery.id) }
      .to have_enqueued_job(described_class).with(delivery.id)
    expect(delivery.reload.status).to eq("retrying")
    expect(delivery.attempts_count).to eq(1)
    expect(delivery.next_retry_at).to be_within(5).of(30.seconds.from_now)
  end

  it "records connection errors as attempts" do
    stub_request(:post, "https://hooks.example.com/wh").to_timeout
    described_class.perform_now(delivery.id)
    expect(delivery.reload.delivery_attempts.sole.error).to be_present
  end

  it "fails terminally after 5 attempts" do
    stub_request(:post, "https://hooks.example.com/wh").to_return(status: 500)
    delivery.update!(attempts_count: 4, status: "retrying")
    described_class.perform_now(delivery.id)
    expect(delivery.reload.status).to eq("failed")
  end

  it "fails immediately when the url no longer passes the guard" do
    allow(Resolv).to receive(:getaddress).and_return("10.0.0.1")
    described_class.perform_now(delivery.id)
    expect(delivery.reload.status).to eq("failed")
    expect(delivery.delivery_attempts.sole.error).to match(/private/)
  end
end
