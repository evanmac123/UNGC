class AddOrganizationsOldTmpId < ActiveRecord::Migration
  def self.up
    add_column :organizations, :old_tmp_id, :integer
  end

  def self.down
    remove_column :organizations, :old_tmp_id
  end
end
