class CreateBulletinSubscribers < ActiveRecord::Migration
  def self.up
    create_table :bulletin_subscribers do |t|
      t.string :first_name
      t.string :last_name
      t.string :organization_name
      t.string :email

      t.timestamps
    end
  end

  def self.down
    drop_table :bulletin_subscribers
  end
end
