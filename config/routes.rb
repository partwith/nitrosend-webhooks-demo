Rails.application.routes.draw do
  root "spa#index"
  get "up" => "rails/health#show", as: :rails_health_check
  # SPA catch-all — API and receiver routes are added ABOVE this line in later tasks
  get "*path", to: "spa#index", constraints: ->(req) { !req.path.start_with?("/api", "/wtm/webhooks", "/vite", "/cable", "/rails") }
end
