class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
      t.integer :old_id
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :prefix
      t.string :job_title
      t.string :email
      t.string :phone
      t.string :mobile
      t.string :fax
      t.integer :organization_id
      t.string :address
      t.string :city
      t.string :state
      t.string :postal_code
      t.integer :country_id
      t.boolean :ceo
      t.boolean :contact_point
      t.boolean :newsletter
      t.boolean :advisory_council
      t.string :login
      t.string :password
      t.string :address_more

      t.timestamps
    end
  end

  def self.down
    drop_table :contacts
  end
end
