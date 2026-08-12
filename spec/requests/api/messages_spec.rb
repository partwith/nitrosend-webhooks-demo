require "rails_helper"

RSpec.describe "POST /api/messages" do
  it "accepts a send, schedules simulation with the configured delay" do
    post "/api/messages", params: { recipient: "a@b.co", subject: "Hi" }, as: :json
    expect(response).to have_http_status(:accepted)
    expect(response.parsed_body.dig("message", "status")).to eq("accepted")
    expect(SimulateSesJob).to have_been_enqueued
  end

  it "blocks suppressed recipients" do
    post "/api/messages", params: { recipient: "a@b.co", subject: "Hi" }, as: :json
    Workspace.sole.suppressions.create!(email: "a@b.co", reason: "550", event_type: "hard_bounce")
    post "/api/messages", params: { recipient: "a@b.co", subject: "Hi" }, as: :json
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body["error"]).to match(/suppress/i)
  end
end
