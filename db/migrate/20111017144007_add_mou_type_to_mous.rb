class AddMouTypeToMous < ActiveRecord::Migration
  def self.up
    add_column :mous, :mou_type, :string
  end

  def self.down
    remove_column :mous, :mou_type
  end
end
