require "rails_helper"

RSpec.describe Webhooks::Signer do
  let(:workspace) { Workspace.create! }
  let(:endpoint) { workspace.webhook_endpoints.create!(url: "https://x.co/h", events: %w[hard_bounce]) }
  let(:body) { %({"event_type":"hard_bounce"}) }
  let(:ts) { Time.current.to_i }

  def sig(secret, timestamp = ts) = described_class.signature(secret:, timestamp:, body:)

  it "produces a stable HMAC-SHA256 hex digest over timestamp.body" do
    expect(described_class.signature(secret: "s", timestamp: 1000, body: "b"))
      .to eq(OpenSSL::HMAC.hexdigest("SHA256", "s", "1000.b"))
  end

  it "accepts a valid signature" do
    expect(described_class.valid?(endpoint:, timestamp: ts, body:, signature: sig(endpoint.signing_secret))).to be true
  end

  it "rejects a tampered body" do
    expect(described_class.valid?(endpoint:, timestamp: ts, body: body + "x", signature: sig(endpoint.signing_secret))).to be false
  end

  it "rejects a stale timestamp" do
    old = 6.minutes.ago.to_i
    expect(described_class.valid?(endpoint:, timestamp: old, body:, signature: sig(endpoint.signing_secret, old))).to be false
  end

  it "accepts the previous secret within the grace window" do
    old_secret = endpoint.signing_secret
    endpoint.rotate_secret!
    expect(described_class.valid?(endpoint:, timestamp: ts, body:, signature: sig(old_secret))).to be true
  end

  it "rejects the previous secret after the grace window" do
    old_secret = endpoint.signing_secret
    endpoint.rotate_secret!
    endpoint.update!(secret_rotated_at: 25.hours.ago)
    expect(described_class.valid?(endpoint:, timestamp: ts, body:, signature: sig(old_secret))).to be false
  end
end
