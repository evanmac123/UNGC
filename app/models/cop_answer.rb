# == Schema Information
#
# Table name: cop_answers
#
#  id               :integer(4)      not null, primary key
#  cop_id           :integer(4)
#  cop_attribute_id :integer(4)
#  value            :boolean(1)
#  created_at       :datetime
#  updated_at       :datetime
#

class CopAnswer < ActiveRecord::Base
  belongs_to :communication_on_progress
  belongs_to :cop_attribute
end
