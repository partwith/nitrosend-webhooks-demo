module Api
  class BookingsController < ApplicationController
    include WorkspaceScoped
    skip_forgery_protection
    rate_limit to: 30, within: 1.minute, only: :send_confirmation

    def index
      render json: {
        bookings: Current.workspace.bookings.order(:id).map(&:as_api_json),
        suppressions: Current.workspace.suppressions.map { |s| s.as_json(only: %i[email reason event_type created_at]) }
      }
    end

    def send_confirmation
      booking = Current.workspace.bookings.find(params[:id])
      booking.update!(email: params[:email].to_s.strip.downcase) if params[:email].present?
      if Current.workspace.suppressions.exists?(email: booking.email)
        return render json: { error: "#{booking.email} is suppressed — Nitrosend blocked this send." }, status: :unprocessable_content
      end
      booking.update!(email_failed_at: nil, failure_reason: nil, confirmation_sent_at: Time.current)
      message = Current.workspace.messages.create!(recipient: booking.email, subject: "Your booking is confirmed 🎉", booking:)
      SimulateSesJob.set(wait: Rails.configuration.x.ses_delay).perform_later(message.id)
      render json: { booking: booking.reload.as_api_json, message: message.as_json(only: %i[id message_id status]) }, status: :accepted
    end
  end
end
