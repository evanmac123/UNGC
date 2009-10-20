class AddApprovalToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :approval, :string
  end

  def self.down
    remove_column :pages, :approval
  end
end
