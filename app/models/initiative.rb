class Initiative < ActiveRecord::Base
  has_many :signings
  has_many :signatories, :through => :signings
  
  FILTER_TYPES = {
    :climate => 2
  }
  
  named_scope :for_filter, lambda { |filter|
    {
      :conditions => [ "initiatives.id = ?", FILTER_TYPES[filter] ]
    }
  }
end
