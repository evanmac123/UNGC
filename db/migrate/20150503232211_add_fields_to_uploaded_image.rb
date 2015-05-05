class AddFieldsToUploadedImage < ActiveRecord::Migration
  def change
    add_column :uploaded_images, :filename, :string
    add_column :uploaded_images, :mime, :string
    add_column :uploaded_images, :created_at, :datetime, null: false
    add_column :uploaded_images, :updated_at, :datetime, null: false
  end
end
