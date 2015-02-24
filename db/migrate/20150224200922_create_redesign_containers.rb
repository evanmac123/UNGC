class CreateRedesignContainers < ActiveRecord::Migration
  def change
    create_table :redesign_containers do |t|
      t.integer :kind, null: false
      t.string  :slug, null: false, default: '/'

      t.integer :parent_container_id
      t.integer :public_payload_id
      t.integer :draft_payload_id

      t.timestamps null: false
    end

    add_index :redesign_containers, :parent_container_id
    add_index :redesign_containers, [:kind, :slug], unique: true
  end
end
