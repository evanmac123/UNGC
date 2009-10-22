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
  belongs_to :country
  has_many :attachments, :class_name => 'UploadedFile', :as => :attachable
  validates_presence_of :title, :on => :create, :message => "^Please provide a title"
  
  def before_approve!
    self.published_on = Date.today
  end

  def full_location
    "#{location}, #{country.try(:name)}"
  end
end
