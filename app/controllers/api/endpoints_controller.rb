module Api
  class EndpointsController < ApplicationController
    include WorkspaceScoped
    skip_forgery_protection
    rate_limit to: 20, within: 1.minute, only: :test_events
    rate_limit to: 10, within: 1.minute, only: %i[create update]

    def index = render json: { endpoints: Current.workspace.webhook_endpoints.order(:created_at).map(&:as_api_json) }
    def show = render json: { endpoint: find_endpoint.as_api_json }

    def create
      guard = Webhooks::UrlGuard.check(params[:url])
      return render json: { errors: [ "URL #{guard.error}" ] }, status: :unprocessable_content unless guard.ok?
      endpoint = Current.workspace.webhook_endpoints.create!(endpoint_params)
      render json: { endpoint: endpoint.as_api_json }, status: :created
    end

    def update
      endpoint = find_endpoint
      if params.key?(:url) && params[:url] != endpoint.url
        guard = Webhooks::UrlGuard.check(params[:url])
        return render json: { errors: [ "URL #{guard.error}" ] }, status: :unprocessable_content unless guard.ok?
      end
      endpoint.update!(endpoint_params)
      render json: { endpoint: endpoint.as_api_json }
    end

    def rotate_secret
      endpoint = find_endpoint
      endpoint.rotate_secret!
      render json: { endpoint: endpoint.as_api_json }
    end

    def test_events
      endpoint = find_endpoint
      event_type = params.require(:event_type)
      head :unprocessable_content and return unless WebhookEndpoint::EVENT_TYPES.include?(event_type)
      event = Current.workspace.webhook_events.create!(event_type:, occurred_at: Time.current, payload: {})
      event.update!(payload: Webhooks::Payload.for(event).merge("test" => true))
      delivery = Current.workspace.webhook_deliveries.create!(webhook_endpoint: endpoint, webhook_event: event)
      WebhookDeliveryJob.perform_later(delivery.id)
      render json: { delivery: delivery.as_api_json }, status: :created
    end

    private

    def find_endpoint = Current.workspace.webhook_endpoints.find(params[:id])

    def endpoint_params
      params.permit(:url, :description, :enabled, events: [])
    end
  end
end
