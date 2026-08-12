class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :workspace, null: false, foreign_key: true
      t.string :learner_name
      t.string :email
      t.string :status, default: "confirmed"
      t.datetime :confirmation_sent_at
      t.datetime :email_failed_at
      t.string :failure_reason

      t.timestamps
    end
  end
end
