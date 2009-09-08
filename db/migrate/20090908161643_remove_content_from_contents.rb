class RemoveContentFromContents < ActiveRecord::Migration
  def self.up
    remove_column :contents, :content
  end

  def self.down
    add_column :contents, :content, :text
  end
end
