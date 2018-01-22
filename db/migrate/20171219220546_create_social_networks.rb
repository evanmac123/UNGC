class CreateSocialNetworks < ActiveRecord::Migration
  def up
    create_table :organization_social_networks do |t|
      t.integer :organization_id, null: false
      t.string :network_code, limit: 30, null: false
      t.string :handle, null: false, limit: 50

      t.timestamps null: false
    end

    add_index :organization_social_networks, [:organization_id, :network_code], unique: true,
              name: :organization_social_networks_pk
    add_index :organization_social_networks, [:network_code, :handle], unique: true,
              name: :index_organization_social_networks_handles

    add_foreign_key :organization_social_networks, :organizations, on_delete: :cascade

  end

  def down
    drop_table :organization_social_networks
  end
end
