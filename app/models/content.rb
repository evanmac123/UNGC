# == Schema Information
#
# Table name: contents
#
#  id         :integer(4)      not null, primary key
#  content    :text
#  path       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Content < ActiveRecord::Base
  serialize :path
  
  def self.for_path(look_for)
    find_by_path look_for
  end
end
