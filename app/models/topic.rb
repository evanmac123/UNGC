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

class Topic < Principle



end
