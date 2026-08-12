module Api
  class DeliveriesController < ApplicationController
    include WorkspaceScoped
    skip_forgery_protection

    def index
      endpoint = Current.workspace.webhook_endpoints.find(params[:endpoint_id])
      deliveries = endpoint.webhook_deliveries.includes(:webhook_event, :delivery_attempts).order(created_at: :desc).limit(50)
      render json: { deliveries: deliveries.map(&:as_api_json) }
    end

    def show
      delivery = Current.workspace.webhook_deliveries.find(params[:id])
      render json: { delivery: delivery.as_api_json(full: true) }
    end
  end
end
