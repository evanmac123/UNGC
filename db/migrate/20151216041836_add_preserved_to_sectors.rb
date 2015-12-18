class AddPreservedToSectors < ActiveRecord::Migration
  def change
    add_column :sectors, :preserved, :boolean, null: false, default: false, index: true
  end
end
