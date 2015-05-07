class UpdateDescriptionForLocalNetwork < ActiveRecord::Migration
  def change
    change_column :local_networks, :description, :text
  end
end
