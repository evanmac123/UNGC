class AddAcceptsEulaToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :accepts_eula, :boolean
  end
end
