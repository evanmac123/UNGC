# == Schema Information
#
# Table name: removal_reasons
#
#  id          :integer(4)      not null, primary key
#  description :string(255)
#  old_id      :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#

class RemovalReason < ActiveRecord::Base
  validates_presence_of :description
  
  FILTERS = {
     :delisted         => 'Expulsion for failure to communicate progress',
     :not_applicable   => 'Not applicable',
     :requested        => 'Participant requested withdrawal',
     :dialogue         => 'Failure to engage in dialogue',
     :blacklisted      => 'Removed due to Blacklisting'
  }
  
  named_scope :for_filter, lambda { |*filter_types|
     if filter_types.is_a?(Array)
       filter_types.map! { |f| FILTERS[f] }
       {:conditions => ["description IN (?)", filter_types]}
     else
       {:conditions => ["description = ?", FILTERS[filter_types]]}
     end
   }
  
   def self.delisted
     first :conditions => { :description => FILTERS[:delisted] }
   end

end
