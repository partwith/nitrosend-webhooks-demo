class CreateDeliveryAttempts < ActiveRecord::Migration[8.1]
  def change
    create_table :delivery_attempts do |t|
      t.references :webhook_delivery, null: false, foreign_key: true
      t.integer :number
      t.integer :http_status
      t.string :response_excerpt
      t.string :error
      t.integer :latency_ms
      t.jsonb :request_headers

      t.timestamps
    end
  end
end
