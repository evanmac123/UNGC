# == Schema Information
#
# Table name: cop_links
#
#  id         :integer(4)      not null, primary key
#  cop_id     :integer(4)
#  name       :string(255)
#  url        :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class CopLink < ActiveRecord::Base
  validates_presence_of :name, :url
  belongs_to :communication_on_progress, :foreign_key => :cop_id
end
