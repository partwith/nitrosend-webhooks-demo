class CreateWebhookEndpoints < ActiveRecord::Migration[8.1]
  def change
    create_table :webhook_endpoints do |t|
      t.references :workspace, null: false, foreign_key: true
      t.string :url
      t.string :description
      t.boolean :enabled, default: true
      t.text :events, array: true, default: []
      t.string :signing_secret
      t.string :previous_secret
      t.datetime :secret_rotated_at

      t.timestamps
    end
  end
end
