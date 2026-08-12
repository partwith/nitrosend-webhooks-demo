require "rails_helper"

RSpec.describe "WTM receiver" do
  let(:workspace) { Workspace.create! }
  let!(:endpoint) { workspace.webhook_endpoints.create!(url: "http://demo.test/wtm/webhooks/#{workspace.token}", events: %w[hard_bounce]) }
  let!(:booking) { workspace.bookings.create!(learner_name: "Sam", email: "bounce@simulator.demo") }

  def payload
    { "event_id" => "evt_1", "event_type" => "hard_bounce", "occurred_at" => Time.current.utc.iso8601,
      "message_id" => "msg_x", "recipient" => "bounce@simulator.demo",
      "reason" => "550 5.1.1 user unknown", "data" => {} }
  end

  def post_signed(body_hash, secret: endpoint.signing_secret, timestamp: Time.current.to_i)
    body = body_hash.to_json
    post "/wtm/webhooks/#{workspace.token}", params: body, headers: {
      "Content-Type" => "application/json",
      "X-Nitrosend-Timestamp" => timestamp.to_s,
      "X-Nitrosend-Signature" => Webhooks::Signer.signature(secret:, timestamp:, body:),
    }
  end

  it "flags the booking on a valid signed event" do
    post_signed(payload)
    expect(response).to have_http_status(:ok)
    expect(booking.reload.email_failed_at).to be_present
    expect(booking.failure_reason).to eq("550 5.1.1 user unknown")
  end

  it "rejects a bad signature" do
    post_signed(payload, secret: "whsec_wrong")
    expect(response).to have_http_status(:unauthorized)
    expect(booking.reload.email_failed_at).to be_nil
  end

  it "rejects a stale timestamp" do
    post_signed(payload, timestamp: 10.minutes.ago.to_i)
    expect(response).to have_http_status(:unauthorized)
  end

  it "404s for unknown workspaces" do
    post "/wtm/webhooks/ws_nope", params: "{}", headers: { "Content-Type" => "application/json" }
    expect(response).to have_http_status(:not_found)
  end
end
