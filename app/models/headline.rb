# == Schema Information
#
# Table name: headlines
#
#  id             :integer(4)      not null, primary key
#  title          :string(255)
#  description    :text
#  location       :string(255)
#  published_on   :date
#  created_by_id  :integer(4)
#  updated_by_id  :integer(4)
#  approval       :string(255)
#  approved_at    :datetime
#  approved_by_id :integer(4)
#  created_at     :datetime
#  updated_at     :datetime
#

class Headline < ActiveRecord::Base
  include ContentApproval
  include TrackCurrentUser
  permalink :title
  validates_presence_of :title, :on => :create, :message => "^Please provide a title"
end
