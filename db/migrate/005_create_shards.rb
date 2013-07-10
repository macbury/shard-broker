class CreateShards < ActiveRecord::Migration
  def self.up
    create_table :shards do |t|
      t.binary  :content, limit: 5 * 1024 * 1024
      t.integer :peer_id
      t.timestamps
    end
  end

  def self.down
    drop_table :shards
  end
end