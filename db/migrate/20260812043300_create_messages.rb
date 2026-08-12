class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.references :workspace, null: false, foreign_key: true
      t.references :booking, null: true, foreign_key: true
      t.string :recipient
      t.string :subject
      t.string :message_id, index: { unique: true }
      t.string :status, default: "accepted"
      t.string :status_reason

      t.timestamps
    end
  end
end
