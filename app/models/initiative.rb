# == Schema Information
#
# Table name: initiatives
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  old_id     :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class Initiative < ActiveRecord::Base
  has_many :signings
  has_many :signatories, :through => :signings
  
  FILTER_TYPES = {
    :climate      => 2,
    :human_rights => 4
  }
  
  named_scope :for_filter, lambda { |filter|
    {
      :conditions => [ "initiatives.id = ?", FILTER_TYPES[filter] ]
    }
  }
end
