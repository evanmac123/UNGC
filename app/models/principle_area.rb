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
#

class PrincipleArea < Principle
end
