class AddLicensingToUploadedImage < ActiveRecord::Migration
  def change
    add_column :uploaded_images, :licensing_data, :text
    add_column :uploaded_images, :has_licensing, :boolean, default: false
  end
end
