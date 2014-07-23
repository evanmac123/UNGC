class RenamePublicListingType < ActiveRecord::Migration
  def up
    ListingStatus.update_all({name: 'Publicly Listed'}, ["name = ?", 'Public Company'])
  end

  def down
    ListingStatus.update_all({name: 'Public Company'}, ["name = ?", 'Publicly Listed'])
  end
end
