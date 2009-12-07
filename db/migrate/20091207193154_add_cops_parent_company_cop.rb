class AddCopsParentCompanyCop < ActiveRecord::Migration
  def self.up
    add_column :communication_on_progresses, :parent_company_cop, :boolean, :default => false
    add_column :communication_on_progresses, :parent_cop_cover_subsidiary, :boolean
  end

  def self.down
    remove_column :communication_on_progresses, :parent_company_cop
    remove_column :communication_on_progresses, :parent_cop_cover_subsidiary
  end
end
