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
  
  validates_presence_of :attachment_type
  validates_presence_of :language, :unless => Proc.new { |link| link.url.blank? } 
  validates_format_of :url,
                      :with => (/(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix),
                      :message => "for website is invalid. Please enter one address in the format http://company.com/",
                      :if => Proc.new { |link| link.url.present? } 
  belongs_to :communication_on_progress, :foreign_key => :cop_id
  belongs_to :language
end
