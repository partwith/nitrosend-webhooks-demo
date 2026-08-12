class CreateWebhookDeliveries < ActiveRecord::Migration[8.1]
  def change
    create_table :webhook_deliveries do |t|
      t.references :workspace, null: false, foreign_key: true
      t.references :webhook_endpoint, null: false, foreign_key: true
      t.references :webhook_event, null: false, foreign_key: true
      t.string :status, default: "pending"
      t.integer :attempts_count, default: 0
      t.datetime :next_retry_at

      t.timestamps
    end
  end
end
