require "rails_helper"

RSpec.describe "SPA shell" do
  it "serves the app shell at root" do
    get "/"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('id="app"')
  end

  it "serves the shell for SPA routes" do
    get "/wtm"
    expect(response).to have_http_status(:ok)
  end
end
