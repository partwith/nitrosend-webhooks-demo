class WorkspaceSeeder
  BOOKINGS = [
    { learner_name: "Maya Chen", email: "maya.chen@example.com" },
    { learner_name: "Tom Okafor", email: "t.okafor@example.com" },
    { learner_name: "Ines Duarte", email: "ines.d@example.com" },
    { learner_name: "Sam Whitlock", email: "bounce@simulator.demo" },
  ].freeze

  def self.seed(workspace, base_url:)
    BOOKINGS.each { |attrs| workspace.bookings.create!(**attrs) }
    workspace.webhook_endpoints.create!(
      url: "#{base_url}/wtm/webhooks/#{workspace.token}",
      description: "WeTeachMe booking system (built-in demo receiver)",
      events: %w[hard_bounce soft_bounce complaint],
    )
  end
end
