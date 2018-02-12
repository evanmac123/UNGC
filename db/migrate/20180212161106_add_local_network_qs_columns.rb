class AddLocalNetworkQsColumns < ActiveRecord::Migration
  def change
    add_column :contacts, :full_time, :boolean, null: true
    add_column :contacts, :employer, :string, null: true, limit: 200
  end
end
