class AddTextIndexToCopAttributes < ActiveRecord::Migration
  def change
    add_index :cop_attributes, :text
  end
end
