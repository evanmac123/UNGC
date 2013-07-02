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
  default_scope :conditions => "name != 'Not applicable'"
end
