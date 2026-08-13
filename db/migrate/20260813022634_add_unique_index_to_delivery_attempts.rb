class AddUniqueIndexToDeliveryAttempts < ActiveRecord::Migration[8.1]
  def change
    add_index :delivery_attempts, %i[webhook_delivery_id number], unique: true
  end
end
