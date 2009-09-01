class AddNavDetailsToContents < ActiveRecord::Migration
  def self.up
    add_column :contents, :label, :string
    add_column :contents, :href, :string
    add_column :contents, :short, :string
    add_column :contents, :parent_id, :integer
    add_column :contents, :position, :integer
  end

  def self.down
    remove_column :contents, :label
    remove_column :contents, :href
    remove_column :contents, :short
    remove_column :contents, :parent_id
    remove_column :contents, :position
  end
end
