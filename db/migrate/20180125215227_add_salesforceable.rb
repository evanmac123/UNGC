class AddSalesforceable < ActiveRecord::Migration
  def change
    create_table :salesforce_records do |t|
      t.string :record_id, limit: 18, null: false, index: {name: :salesforce_record_id_uidx, unique: true }
      t.references :rails, polymorphic: true, index: {name: :salesforce_rails_type_idx }

      t.timestamps null: false
    end
  end
end
