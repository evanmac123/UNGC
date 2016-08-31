class AddSectorIndexes < ActiveRecord::Migration
  def change
    add_index :sectors, :name
    add_index :organizations, :sector_id
  end
end
