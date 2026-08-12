require "rails_helper"

RSpec.describe "Full suppression webhook loop", type: :system do
  it "flags a booking after a simulated hard bounce, live" do
    visit "/wtm"
    expect(page).to have_content("Bookings")

    within("li", text: "Sam Whitlock") do
      click_button "Send confirmation"
      expect(page).to have_content("Email failed — 550 5.1.1 user unknown", wait: 10)
    end

    visit "/"
    # The endpoints table row is a clickable <tr>, not an <a>/<button>, so we
    # click the row by its URL text rather than using click_on.
    find("tr", text: WebhookEndpoint.sole.url).click
    expect(page).to have_content("hard bounce")
    expect(page).to have_selector(".badge", text: "delivered")
  end
end
