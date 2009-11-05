class AddTopLevelToPages < ActiveRecord::Migration
  def self.up
    # TODO: Remove this column after final data import - it's only used during CMS import
    add_column :pages, :top_level, :boolean
  end

  def self.down
    remove_column :pages, :top_level
  end
end
