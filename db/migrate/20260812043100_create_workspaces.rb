class CreateWorkspaces < ActiveRecord::Migration[8.1]
  def change
    create_table :workspaces do |t|
      t.string :token
      t.datetime :last_seen_at

      t.timestamps
    end
    add_index :workspaces, :token, unique: true
  end
end
