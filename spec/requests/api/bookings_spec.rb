require "rails_helper"

RSpec.describe "Bookings API" do
  it "lists seeded bookings and sends a confirmation with an overridden email" do
    get "/api/bookings"
    bookings = response.parsed_body["bookings"]
    expect(bookings.length).to eq(4)

    id = bookings.first["id"]
    post "/api/bookings/#{id}/send_confirmation", params: { email: "bounce@simulator.demo" }, as: :json
    expect(response).to have_http_status(:accepted)
    expect(Booking.find(id).email).to eq("bounce@simulator.demo")
    expect(SimulateSesJob).to have_been_enqueued
  end
end
