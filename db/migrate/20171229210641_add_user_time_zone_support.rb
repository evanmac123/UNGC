class AddUserTimeZoneSupport < ActiveRecord::Migration
  def change
    add_column :contacts, :time_zone, :string,
               limit: 32, null: false, default: 'UTC'
  end
end
