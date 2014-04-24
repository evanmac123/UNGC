# == Schema Information
#
# Table name: listing_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  old_id     :integer
#  created_at :datetime
#  updated_at :datetime
#

class ListingStatus < ActiveRecord::Base
  validates_presence_of :name

  def self.not_applicable
    find_by_name("Not Applicable")
  end

  def self.applicable
    where("name <> 'Not Applicable'")
  end

end
