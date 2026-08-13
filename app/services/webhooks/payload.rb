module Webhooks
  class Payload
    DETAILS = {
      "hard_bounce" => { reason: "550 5.1.1 user unknown",
                         data: { "bounce_type" => "Permanent", "diagnostic_code" => "smtp; 550 5.1.1 user unknown" } },
      "soft_bounce" => { reason: "452 4.2.2 mailbox full",
                         data: { "bounce_type" => "Transient", "diagnostic_code" => "smtp; 452 4.2.2 mailbox full" } },
      "complaint"   => { reason: "abuse",
                         data: { "complaint_feedback_type" => "abuse" } }
    }.freeze

    def self.for(event)
      d = DETAILS.fetch(event.event_type)
      {
        "event_id" => "evt_#{event.id}",
        "event_type" => event.event_type,
        "occurred_at" => event.occurred_at.utc.iso8601,
        "message_id" => event.message&.message_id,
        "recipient" => event.message&.recipient,
        "reason" => d[:reason],
        "data" => d[:data]
      }
    end
  end
end
