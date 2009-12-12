class AddIndexForPageApproval < ActiveRecord::Migration
  def self.up
    add_index :pages, :approval
  end

  def self.down
    remove_index :pages, :approval
  end
end
