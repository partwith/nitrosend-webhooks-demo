require "rails_helper"

RSpec.describe "Endpoints API" do
  before { allow(Resolv).to receive(:getaddress).and_return("93.184.216.34") }

  it "creates, lists, updates, rotates" do
    post "/api/endpoints", params: { url: "https://hooks.example.com/wh", events: %w[hard_bounce] }, as: :json
    expect(response).to have_http_status(:created)
    id = response.parsed_body.dig("endpoint", "id")

    get "/api/endpoints"
    urls = response.parsed_body["endpoints"].map { it["url"] }
    expect(urls).to include("https://hooks.example.com/wh")

    patch "/api/endpoints/#{id}", params: { enabled: false, events: %w[hard_bounce complaint] }, as: :json
    expect(response.parsed_body.dig("endpoint", "enabled")).to be false

    expect { post "/api/endpoints/#{id}/rotate_secret" }
      .to change { WebhookEndpoint.find(id).signing_secret }
  end

  it "rejects guarded urls with the guard's message" do
    allow(Resolv).to receive(:getaddress).and_return("10.0.0.1")
    post "/api/endpoints", params: { url: "https://internal.corp/wh", events: %w[hard_bounce] }, as: :json
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body["errors"].join).to match(/private/)
  end

  it "creates a test event delivery through the real pipeline" do
    post "/api/endpoints", params: { url: "https://hooks.example.com/wh", events: %w[hard_bounce] }, as: :json
    id = response.parsed_body.dig("endpoint", "id")
    expect { post "/api/endpoints/#{id}/test_events", params: { event_type: "hard_bounce" }, as: :json }
      .to have_enqueued_job(WebhookDeliveryJob)
    expect(response.parsed_body.dig("delivery", "status")).to eq("pending")
  end

  it "cannot touch another workspace's endpoint" do
    other = Workspace.create!
    foreign = other.webhook_endpoints.create!(url: "https://x.co/h", events: %w[hard_bounce])
    get "/api/endpoints/#{foreign.id}"   # establishes this session's own workspace
    expect(response).to have_http_status(:not_found)
  end
end
