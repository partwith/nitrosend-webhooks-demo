class CreateWebhookEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :webhook_events do |t|
      t.references :workspace, null: false, foreign_key: true
      t.string :event_type
      t.jsonb :payload
      t.references :message, null: true, foreign_key: true
      t.datetime :occurred_at

      t.timestamps
    end
  end
end
