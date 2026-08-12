module Webhooks
  class UrlGuard
    BLOCKED_RANGES = %w[
      0.0.0.0/8 10.0.0.0/8 100.64.0.0/10 127.0.0.0/8 169.254.0.0/16
      172.16.0.0/12 192.168.0.0/16 198.18.0.0/15 ::1/128 fc00::/7 fe80::/10
    ].map { |cidr| IPAddr.new(cidr) }.freeze

    Result = Struct.new(:error, :uri, :ip, keyword_init: true) do
      def ok? = error.nil?
    end

    def self.check(url_string)
      uri = begin
        URI.parse(url_string.to_s)
      rescue URI::InvalidURIError
        nil
      end
      return fail!("isn't a valid URL") unless uri.is_a?(URI::HTTP) && uri.host.present?

      ip = begin
        Resolv.getaddress(uri.host)
      rescue Resolv::ResolvError
        return fail!("host could not be resolved")
      end
      addr = IPAddr.new(ip)
      unless uri.host == "localhost" && !Rails.env.production?
        return fail!("resolves to a private or reserved address, which this demo can't deliver to") if BLOCKED_RANGES.any? { |r| r.include?(addr) }
      end

      Result.new(uri:, ip:)
    end

    def self.fail!(message) = Result.new(error: message)
    private_class_method :fail!
  end
end
