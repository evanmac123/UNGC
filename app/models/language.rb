# == Schema Information
#
# Table name: languages
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  old_id     :integer
#  created_at :datetime
#  updated_at :datetime
#

class Language < ActiveRecord::Base
  validates_presence_of :name
  has_and_belongs_to_many :communication_on_progresses

  default_scope { order(:name) }

  FILTERS = {
    :english => 'English',
    :french  => 'French'
  }

  def self.for(name)
    find_by(name: name&.titleize)
  end

  def self.method_missing(m, *args, &block)
    if FILTERS.keys.include?(m)
      self.for(FILTERS[m])
    else
      super(m, *args, &block)
    end
  end

  def self.default_language_id
    @_default_language_id ||= english&.id
  end
end
