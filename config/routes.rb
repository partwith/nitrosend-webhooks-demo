Rails.application.routes.draw do
  root "spa#index"
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    resources :messages, only: :create
    resources :endpoints, only: %i[index show create update] do
      member do
        post :rotate_secret
        post :test_events
      end
      resources :deliveries, only: :index
    end
    resources :deliveries, only: :show
    resources :bookings, only: :index do
      member { post :send_confirmation }
    end
  end

  post "wtm/webhooks/:workspace_token", to: "wtm/webhooks#create"

  # SPA catch-all — API and receiver routes are added ABOVE this line in later tasks
  get "*path", to: "spa#index", constraints: ->(req) { !req.path.start_with?("/api", "/wtm/webhooks", "/vite", "/cable", "/rails") }
end
