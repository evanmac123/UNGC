class RenameIssueAreaToIssue < ActiveRecord::Migration
  def change
    remove_foreign_key :issues, column: :issue_area_id
    rename_column :issues, :issue_area_id, :parent_id
    add_foreign_key :issues, :issues, column: :parent_id
  end
end
