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
  has_many :cop_questions
  has_many :roles
  default_scope :order => 'name'
  
  after_create :create_initiative_role
  
  FILTER_TYPES = {
    :climate      => 2,
    :human_rights => 4
  }
  
  named_scope :for_filter, lambda { |filter|
    {
      :conditions => [ "initiatives.id = ?", FILTER_TYPES[filter] ]
    }
  }
  
  private
    def create_initiative_role
      Role.create(:name          => name,
                  :initiative_id => id)
    end
end
