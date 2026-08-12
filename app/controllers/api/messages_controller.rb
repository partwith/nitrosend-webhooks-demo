module Api
  class MessagesController < ApplicationController
    include WorkspaceScoped
    skip_forgery_protection
    rate_limit to: 30, within: 1.minute, only: :create

    def create
      recipient = params.require(:recipient).to_s.strip.downcase
      if Current.workspace.suppressions.exists?(email: recipient)
        return render json: { error: "#{recipient} is on the suppression list — sends to it are blocked." }, status: :unprocessable_content
      end
      message = Current.workspace.messages.create!(
        recipient:, subject: params[:subject].presence || "(no subject)",
        booking_id: Current.workspace.bookings.find_by(id: params[:booking_id])&.id,
      )
      SimulateSesJob.set(wait: Rails.configuration.x.ses_delay).perform_later(message.id)
      render json: { message: message.as_json(only: %i[id recipient subject message_id status]) }, status: :accepted
    end
  end
end
