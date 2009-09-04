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
end
