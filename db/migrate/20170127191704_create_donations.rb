class CreateDonations < ActiveRecord::Migration
  def up
    create_table :donations do |t|
      t.monetize :amount, null: false
      t.string :job_title, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :company_name, null: false
      t.string :address, null: false
      t.string :address_more
      t.string :city, null: false
      t.string :state, null: false
      t.string :postal_code, null: false
      t.string :country_name, null: false
      t.string :email_address, null: false
      t.integer :contact_id, foreign_key: true
      t.integer :organization_id, foreign_key: true
      t.string :reference, null: false
      t.string :response_id
      t.text :full_response
      t.integer :status

      t.timestamps null: false
    end
    change_column :donations, :amount_cents, :integer, limit: 8
  end

  def down
    drop_table :donations
  end
end
