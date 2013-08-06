class ResourceLink < ActiveRecord::Base
  belongs_to :resource
  belongs_to :language

  validates_presence_of :title, :link_type

  TYPES = {
    :web => 'Website',
    :pdf => 'PDF',
    :mp3 => 'MP3 audio file',
    :ppt => 'PowerPoint presentation'
  }

  validates :link_type, :inclusion => { :in => TYPES.keys.to_s, :message => "%{value} is not a valid link_type value" }

end
