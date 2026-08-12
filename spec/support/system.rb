# System tests drive a real headless Chrome against a real, locally-running
# copy of the Rails app (via Capybara's Puma server on a random port). Bind
# that server to "localhost" (not the 127.0.0.1 default) so that
# `request.base_url` — the URL WorkspaceSeeder writes as the demo webhook
# endpoint — comes back as "http://localhost:PORT" and passes
# Webhooks::UrlGuard's `uri.host == "localhost"` bypass instead of being
# rejected as a private/loopback address.
Capybara.server_host = "localhost"
Capybara.server = :puma, { Silent: true }

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless=new")
  options.add_argument("--window-size=1400,900")
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :headless_chrome
    # Jobs must actually run: use good_job inline for system tests
    ActiveJob::Base.queue_adapter = GoodJob::Adapter.new(execution_mode: :inline)
  end
  config.after(:each, type: :system) { ActiveJob::Base.queue_adapter = :test }
end
