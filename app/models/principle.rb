# == Schema Information
#
# Table name: principles
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  old_id     :integer
#  created_at :datetime
#  updated_at :datetime
#  type       :string(255)
#  parent_id  :integer
#

class Principle < ActiveRecord::Base
  validates_presence_of :name
  has_and_belongs_to_many :communication_on_progresses
  acts_as_tree

  TYPE_NAMES = { :global_compact       => "Global Compact",
                 :human_rights         => "Human Rights",
                 :labour               => "Labour",
                 :environment          => "Environment",
                 :anti_corruption      => "Anti-Corruption",
                 :business_peace       => 'Business and Peace',
                 :financial_markets    => "Financial Markets",
                 :business_development => "Business for Development",
                 :un_business          => "UN / Business Partnerships",
                 :supply_chain         => "Supply Chain Sustainability"
                }


  def self.by_types(filter_type)
   if filter_type.is_a?(Array)
     types = filter_type.map { |t| TYPE_NAMES[t] }
     where("name IN (?)", types)
   else
     where("name = ?", TYPE_NAMES[filter_type])
   end
  end

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
