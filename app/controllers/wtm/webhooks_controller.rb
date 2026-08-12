module Wtm
  class WebhooksController < ActionController::API
    def create
      workspace = Workspace.find_by(token: params[:workspace_token])
      return head :not_found unless workspace

      body = request.raw_post
      timestamp = request.headers["X-Nitrosend-Timestamp"].to_i
      signature = request.headers["X-Nitrosend-Signature"].to_s
      verified = workspace.webhook_endpoints.any? do |endpoint|
        Webhooks::Signer.valid?(endpoint:, timestamp:, body:, signature:)
      end
      return render json: { error: "signature verification failed" }, status: :unauthorized unless verified

      event = JSON.parse(body)
      booking = workspace.bookings.find_by(email: event["recipient"].to_s.downcase)
      booking&.update!(email_failed_at: Time.current, failure_reason: event["reason"])
      WorkspaceBroadcaster.booking_updated(booking) if booking
      render json: { received: true }
    end
  end
end
