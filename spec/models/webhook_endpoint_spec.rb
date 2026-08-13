require "rails_helper"

RSpec.describe WebhookEndpoint do
  let(:workspace) { Workspace.create! }
  let(:endpoint) { workspace.webhook_endpoints.create!(url: "https://example.com/hooks", events: %w[hard_bounce]) }

  it "generates a whsec_ secret" do
    expect(endpoint.signing_secret).to match(/\Awhsec_[A-Za-z0-9]{32}\z/)
  end

  it "rotates the secret keeping the previous one" do
    old = endpoint.signing_secret
    endpoint.rotate_secret!
    expect(endpoint.signing_secret).not_to eq(old)
    expect(endpoint.previous_secret).to eq(old)
    expect(endpoint.secret_rotated_at).to be_within(2).of(Time.current)
  end

  it "knows its subscriptions" do
    expect(endpoint.subscribed_to?("hard_bounce")).to be true
    expect(endpoint.subscribed_to?("complaint")).to be false
  end

  it "requires a valid http(s) url" do
    e = workspace.webhook_endpoints.new(url: "ftp://x", events: %w[hard_bounce])
    expect(e).not_to be_valid
  end

  it "rejects a url with an embedded newline and a second scheme" do
    e = workspace.webhook_endpoints.new(url: "https://example.com/x\njavascript://alert(1)", events: %w[hard_bounce])
    expect(e).not_to be_valid
  end
end
