class CreateRelations < ActiveRecord::Migration
  def self.up
    create_table :relationships do |t|
      t.integer :user_id,     null: false
      t.integer :partner_id,  null: false
      t.boolean :accepted,    default: false
    end
  end

  def self.down
    drop_table :relationships
  end
end