class AddVideoEmbedToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :video_embed, :string, limit: 500
  end
end
