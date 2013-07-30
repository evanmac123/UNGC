class DropBulletinSubscribersTable < ActiveRecord::Migration
  def up
    drop_table :bulletin_subscribers
  end

  def down
    create_table :bulletin_subscribers do |t|
      t.string   :first_name
      t.string   :last_name
      t.string   :organization_name
      t.string   :email
      t.timestamps
    end
  end

end
