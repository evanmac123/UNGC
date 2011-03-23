class RemoveOldTmpIdFromOrganizations < ActiveRecord::Migration
  def self.up
    remove_column :organizations, :old_tmp_id
  end

  def self.down
    add_column :organizations, :old_tmp_id, :integer
  end
end
