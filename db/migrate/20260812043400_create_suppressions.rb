class CreateSuppressions < ActiveRecord::Migration[8.1]
  def change
    create_table :suppressions do |t|
      t.references :workspace, null: false, foreign_key: true
      t.string :email
      t.string :reason
      t.string :event_type

      t.timestamps
    end
    add_index :suppressions, %i[workspace_id email], unique: true
  end
end
