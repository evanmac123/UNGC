# == Schema Information
#
# Table name: principles
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  old_id     :integer(4)
#  created_at :datetime
#  updated_at :datetime
#  type       :string(255)
#  parent_id  :integer(4)
#

class Principle < ActiveRecord::Base
  validates_presence_of :name
  has_and_belongs_to_many :communication_on_progresses
  acts_as_tree

  TYPE_NAMES = { :human_rights         => "Human Rights",
                 :labour               => "Labour",
                 :environment          => "Environment",
                 :anti_corruption      => "Anti-Corruption",
                 :business_peace       => 'Business and Peace',
                 :financial_markets    => "Financial Markets",
                 :business_development => "Business for Development",
                 :un_business          => "UN / Business Partnerships",
                 :supply_chain         => "Supply Chain Sustainability"
                }


  named_scope :by_types, lambda { |filter_type|
     if filter_type.is_a?(Array)
       types = filter_type.map { |t| TYPE_NAMES[t] }
       {:conditions => ["name IN (?)", types]}
     else
       {:conditions => ["name = ?", TYPE_NAMES[filter_type]]}
     end
   }

  def self.all_types
    types = []
    Principle::TYPE_NAMES.each do |key,value|
      types << Principle.by_type(key)
    end
    types
  end

  def self.by_type(type)
    Principle.find_by_name(TYPE_NAMES[type])
  end

  def self.principles_for_issue_area(area)
    PrincipleArea.area_for(PrincipleArea::FILTERS[area]).children
  end

end
