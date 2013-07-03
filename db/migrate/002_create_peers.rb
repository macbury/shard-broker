class CreatePeers < ActiveRecord::Migration
  def self.up
    create_table :peers do |t|
      t.integer :user_id, null: false
      t.string :token, null: false
      t.string :encryption_key, null: false, limit: 1024
      t.string :signing_key, null: false, limit: 1024
      t.string :device_id, null: false
      t.timestamps
    end
  end

  def self.down
    drop_table :peers
  end
end