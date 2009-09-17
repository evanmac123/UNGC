class ContentTemplate < ActiveRecord::Base
  has_many :content_versions
  
  def self.default
    find_by_default(true)
  end

  def dynamic?
    label == 'Dynamic' # FIXME
  end
end
