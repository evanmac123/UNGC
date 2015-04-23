class RenameIssueAreaToIssue < ActiveRecord::Migration
  def change
    rename_column :issues, :issue_area_id, :parent_id
  end
end
