class ResourceLink < ActiveRecord::Base
  belongs_to :resource
  belongs_to :language

  validates_presence_of :title, :link_type

  TYPES = {
    :doc => 'Word document',
    :mp3 => 'MP3 audio file',
    :pdf => 'PDF',
    :ppt => 'PowerPoint presentation',
    :web => 'Website'
  }

  validates :link_type, :inclusion => { :in => TYPES.keys.to_s, :message => "%{value} is not a valid link_type value" }

  def increment_views!
    self.increment! :views
  end

end
