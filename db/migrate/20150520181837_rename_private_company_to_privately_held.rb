class RenamePrivateCompanyToPrivatelyHeld < ActiveRecord::Migration
  def up
    status = ListingStatus.find_by(name: "Private Company")
    status.update_attribute(:name, "Privately Held") if status.present?
  end

  def down
    status = ListingStatus.find_by(name: "Privately Held")
    status.update_attribute(:name, "Private Company") if status.present?
  end
end
