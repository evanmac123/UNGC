class Tagging < ActiveRecord::Base
  # domains
  belongs_to :author
  belongs_to :principle, polymorphic: true
  belongs_to :country
  belongs_to :initiative
  belongs_to :language
  belongs_to :sector

  # subjects
  belongs_to :communication_on_progress
  belongs_to :event
  belongs_to :headline
  belongs_to :organization
  belongs_to :redesign_container, class_name: "Redesign::Container"
  belongs_to :resource
  belongs_to :container

  def domain
    author || principle || country || initiative || language || sector
  end

  def subject
    communication_on_progress ||event ||headline ||organization ||redesign_container ||resource || container
  end

end
