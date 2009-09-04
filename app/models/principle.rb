# == Schema Information
#
# Table name: principles
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  old_id     :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class Principle < ActiveRecord::Base
  validates_presence_of :name
  has_and_belongs_to_many :communication_on_progresses
end
