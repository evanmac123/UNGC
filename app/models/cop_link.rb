# == Schema Information
#
# Table name: cop_links
#
#  id              :integer(4)      not null, primary key
#  cop_id          :integer(4)
#  url             :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  attachment_type :string(255)
#  language_id     :integer(4)
#

class CopLink < ActiveRecord::Base
  validates_presence_of :attachment_type, :url
  belongs_to :communication_on_progress, :foreign_key => :cop_id
  belongs_to :language
end
