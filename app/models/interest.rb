# == Schema Information
#
# Table name: interests
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  old_id     :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class Interest < ActiveRecord::Base
  validates_presence_of :name
end
