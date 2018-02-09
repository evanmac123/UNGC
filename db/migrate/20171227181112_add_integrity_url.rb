class AddIntegrityUrl < ActiveRecord::Migration
  def change
    add_column :organizations, :government_registry_url, :string, limit: 2_000
  end
end
