# == Schema Information
#
# Table name: sponsors
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  website_url :string(255)
#  logo_url    :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Sponsor < ActiveRecord::Base
  has_many :event_sponsors, dependent: :destroy
  has_many :events, through: :event_sponsors

  validates :name, presence: true
  validates :website_url, length: { maximum: 255, too_long: "has a %{count} character limit" }
  validates :logo_url, length: { maximum: 255, too_long: "has a %{count} character limit" }
  validates_format_of [:website_url, :logo_url],
                      :with => /\A(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix,
                      :message => 'is invalid. Please enter one address in the format http://unglobalcompact.org/',
                      :unless => Proc.new { |sponsor| sponsor.website_url.blank? }
end
