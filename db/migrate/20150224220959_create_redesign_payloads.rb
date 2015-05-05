class CreateRedesignPayloads < ActiveRecord::Migration
  def change
    create_table :redesign_payloads do |t|
      t.integer :container_id, null: false
      t.text :json_data, null: false
      t.timestamps null: false
    end
  end
end
