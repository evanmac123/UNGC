class Sponsor < ActiveRecord::Base
  validates :name, presence: true
  validates_format_of [:website_url, :logo_url],
                      :with => /\A(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix,
                      :message => 'is invalid. Please enter one address in the format http://unglobalcompact.org/',
                      :unless => Proc.new { |sponsor| sponsor.website_url.blank? }
end
