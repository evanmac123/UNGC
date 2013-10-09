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
#  reference  :string(255)
#

class PrincipleArea < Principle
  has_many :cop_attributes

  FILTERS = {
    :human_rights    => "Human Rights",
    :labour          => "Labour",
    :environment     => "Environment",
    :anti_corruption => "Anti-Corruption"
  }

  def self.area_for(name)
    first(:conditions => {:name => name})
  end

  def self.method_missing(m, *args, &block)
     if FILTERS.keys.include?(m)
       self.area_for(FILTERS[m])
     else
       super(m, *args, &block)
     end
   end
end
