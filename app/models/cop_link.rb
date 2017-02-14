# == Schema Information
#
# Table name: cop_links
#
#  id              :integer          not null, primary key
#  cop_id          :integer
#  url             :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  attachment_type :string(255)
#  language_id     :integer
#

class CopLink < ActiveRecord::Base

  validates_presence_of :attachment_type
  validates_presence_of :language, :unless => Proc.new { |link| link.url.blank? }
  validates_format_of :url,
                      with: URI::regexp(['http', 'https']),
                      message: "for website is invalid. Please enter one address in the format http://company.com/",
                      if: Proc.new { |link| link.url.present? }
  validates :url, length: { maximum: 255, too_long: "has a %{count} character limit" }
  belongs_to :communication_on_progress, :foreign_key => :cop_id
  belongs_to :language
end
