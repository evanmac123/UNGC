class AddImageToContacts < ActiveRecord::Migration
  def change
    add_attachment :contacts, :image
  end
end
