# frozen_string_literal: true

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
  has_many :cop_questions
  has_many :cop_attributes, through: :cop_questions

  default_scope {
    order(ORDERED_FIELDS)
  }

  ORDERED_AREA_NAMES = ['Human Rights', 'Labour', 'Environment', 'Anti-Corruption']
  ORDERED_FIELDS = AnsiSqlHelper.fields_as_case('principles.name', ORDERED_AREA_NAMES)

  FILTERS = {
    :human_rights    => "Human Rights",
    :labour          => "Labour",
    :environment     => "Environment",
    :anti_corruption => "Anti-Corruption"
  }

  def self.area_for(name)
    find_by(name: name)
  end

  def self.method_missing(m, *args, &block)
     if FILTERS.keys.include?(m)
       self.area_for(FILTERS[m])
     else
       super(m, *args, &block)
     end
   end
end
