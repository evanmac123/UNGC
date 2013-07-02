# == Schema Information
#
# Table name: cop_scores
#
#  id          :integer          not null, primary key
#  description :string(255)
#  old_id      :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class CopScore < ActiveRecord::Base
  validates_presence_of :description

  def self.notable
    find_by_description('Notable')
  end
end
