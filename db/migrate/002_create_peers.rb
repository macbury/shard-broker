class CreatePeers < ActiveRecord::Migration
  def self.up
    create_table :peers do |t|
      t.integer :user_id, null: false
      t.string :token, null: false
      t.string :encryption_key, null: false, limit: 1024
      t.string :signing_key, null: false, limit: 1024
      t.string :device_id, null: false
      t.string :gcm_registration_id
      t.string :chunk_hash
      t.date   :chunk_date

      t.datetime :last_login
      t.timestamps
    end
  end

  def self.down
    drop_table :peers
  end
end