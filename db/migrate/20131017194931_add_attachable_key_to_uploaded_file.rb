class AddAttachableKeyToUploadedFile < ActiveRecord::Migration
  def change
    add_column :uploaded_files, :attachable_key, :string
  end
end
