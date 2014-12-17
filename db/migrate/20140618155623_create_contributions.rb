class CreateContributions < ActiveRecord::Migration
  def change
    create_table :contributions do |t|
      t.string  :contribution_id, null: false
      t.string  :invoice_code
      t.integer :raw_amount
      t.integer :recognition_amount
      t.date    :date, null: false
      t.string  :stage, null: false
      t.string  :payment_type
      t.integer :organization_id, null: false
      t.string :campaign_id
      t.boolean :is_deleted, null: false, default: false
      t.timestamps
    end

    add_index :contributions, :contribution_id, unique: true
    add_index :contributions, :organization_id
    add_index :contributions, :campaign_id
  end
end
