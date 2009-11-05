class RenameSlugColumnsPagesAndGroups < ActiveRecord::Migration
  def self.up
    rename_column :pages, :slug, :html_code
    rename_column :page_groups, :slug, :html_code
  end

  def self.down
    rename_column :pages, :html_code, :slug
    rename_column :page_groups, :html_code, :slug
  end
end
