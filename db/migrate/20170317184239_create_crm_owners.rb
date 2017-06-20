class CreateCrmOwners < ActiveRecord::Migration
  def change
    create_table :crm_owners do |t|
      t.references :contact, null: false
      t.string :crm_id, null: false

      t.timestamps null: false
    end
    
    add_index :crm_owners, :contact_id, unique: true
    add_foreign_key :crm_owners, :contacts
  end
end
