module Webhooks
  class Signer
    TOLERANCE = 5.minutes

    def self.signature(secret:, timestamp:, body:)
      OpenSSL::HMAC.hexdigest("SHA256", secret, "#{timestamp}.#{body}")
    end

    def self.valid?(endpoint:, timestamp:, body:, signature:, at: Time.current)
      return false if (at.to_i - timestamp.to_i).abs > TOLERANCE
      valid_secrets(endpoint, at).any? do |secret|
        ActiveSupport::SecurityUtils.secure_compare(signature(secret:, timestamp:, body:), signature.to_s)
      end
    end

    def self.valid_secrets(endpoint, at)
      secrets = [endpoint.signing_secret]
      if endpoint.previous_secret.present? && endpoint.secret_rotated_at && endpoint.secret_rotated_at > at - WebhookEndpoint::GRACE_WINDOW
        secrets << endpoint.previous_secret
      end
      secrets
    end
  end
end
