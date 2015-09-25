class AddUniqueIndexToOrganizationName < ActiveRecord::Migration
  def change
    # TODO enable this when all of the existing duplicates have been cleared out.
    # add_index :organizations, :name, unique: true
  end
end
