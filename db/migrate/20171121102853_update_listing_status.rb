class UpdateListingStatus < ActiveRecord::Migration
  def up
    transaction do
      subsidiary = ListingStatus.find_by!(name: 'Subsidiary')

      Organization
          .where(listing_status_id: subsidiary)
          .update_all(listing_status_id: nil)

      subsidiary.destroy!
    end

    add_index :organizations, :listing_status_id
    add_foreign_key :organizations, :listing_statuses, on_delete: :nullify
  end

  def down
    ListingStatus.create!(name: 'Subsidiary')

    remove_foreign_key :organizations, :listing_statuses
    remove_index :organizations, :listing_status_id
  end

end
