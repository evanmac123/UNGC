# == Schema Information
#
# Table name: resource_links
#
#  id          :integer          not null, primary key
#  url         :string(255)
#  title       :string(255)
#  link_type   :string(255)
#  resource_id :integer
#  language_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  views       :integer          default(0)
#

class ResourceLink < ActiveRecord::Base
  belongs_to :resource
  belongs_to :language

  validates_presence_of :title, :link_type

  TYPES = {
    :doc => 'Word document',
    :mp3 => 'MP3 audio file',
    :pdf => 'PDF',
    :ppt => 'PowerPoint presentation',
    :web => 'Website',
    :video => 'Video'
  }

  validates :link_type, :inclusion => {:in => TYPES.keys.map(&:to_s), :message => "%{value} is not a valid link_type value" }

  scope :videos, -> { where('link_type = "video"') }

  def increment_views!
    self.increment! :views
  end

  def url=(url)
    write_attribute(:url, url.try(:strip))
  end

  def url
    read_attribute(:url).try(:strip)
  end

end
