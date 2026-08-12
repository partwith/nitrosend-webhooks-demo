class WorkspaceBroadcaster
  def self.delivery_updated(delivery)
    push(delivery.workspace, "delivery.updated", delivery.as_api_json)
  end

  def self.booking_updated(booking)
    push(booking.workspace, "booking.updated", booking.as_api_json)
  end

  def self.message_updated(message)
    push(message.workspace, "message.updated", message.as_json(only: %i[id message_id recipient status status_reason booking_id]))
  end

  def self.push(workspace, type, data)
    WorkspaceChannel.broadcast_to(workspace, { "type" => type, "data" => data })
  end
end
