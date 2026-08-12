class WorkspaceSeeder
  BOOKINGS = [
    { learner_name: "Maya Chen", email: "maya.chen@example.com" },
    { learner_name: "Tom Okafor", email: "t.okafor@example.com" },
    { learner_name: "Ines Duarte", email: "ines.d@example.com" },
    { learner_name: "Sam Whitlock", email: "bounce@simulator.demo" },
  ].freeze

  def self.seed(workspace, base_url:)
    BOOKINGS.each { |attrs| workspace.bookings.create!(**attrs) }
    # Workspace#webhook_endpoints doesn't exist until Task 4 (its has_many is
    # commented out until then). This check makes seeding degrade gracefully
    # in the interim rather than crashing every request; once Task 4 lands,
    # respond_to? is always true and this guard is a permanent no-op that
    # Task 4 should remove.
    return unless workspace.respond_to?(:webhook_endpoints)

    workspace.webhook_endpoints.create!(
      url: "#{base_url}/wtm/webhooks/#{workspace.token}",
      description: "WeTeachMe booking system (built-in demo receiver)",
      events: %w[hard_bounce soft_bounce complaint],
    )
  end
end
