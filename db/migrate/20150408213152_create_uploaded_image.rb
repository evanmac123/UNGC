class CreateUploadedImage < ActiveRecord::Migration
  def change
    create_table :uploaded_images do |t|
      t.string  :url, null: false
    end
  end
end
