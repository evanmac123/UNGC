class AddParentIdToPrinciples < ActiveRecord::Migration
  def self.up
    add_column :principles, :parent_id, :integer
  end

  def self.down
    remove_column :principles, :parent_id
  end
end
