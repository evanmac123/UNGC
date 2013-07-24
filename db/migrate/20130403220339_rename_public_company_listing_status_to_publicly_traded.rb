class RenamePublicCompanyListingStatusToPubliclyTraded < ActiveRecord::Migration
  def self.up
    ListingStatus.update_all({:name => 'Publicly Listed'}, {:name => "Public Company"})
  end

  def self.down
    ListingStatus.update_all({:name => 'Public Company'}, {:name => "Publicly Listed"})
  end
end