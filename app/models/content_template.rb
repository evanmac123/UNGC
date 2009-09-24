# == Schema Information
#
# Table name: content_templates
#
#  id         :integer(4)      not null, primary key
#  filename   :string(255)
#  label      :string(255)
#  default    :boolean(1)
#  created_at :datetime
#  updated_at :datetime
#

class ContentTemplate < ActiveRecord::Base
  has_many :content_versions
  
  def self.default
    find_by_default(true)
  end

  def dynamic?
    label == 'Dynamic' # FIXME
  end
end
