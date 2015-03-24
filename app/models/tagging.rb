class Tagging < ActiveRecord::Base
  # domains
  belongs_to :author
  belongs_to :principle
  belongs_to :topic
  belongs_to :issue
  belongs_to :country
  belongs_to :initiative
  belongs_to :language
  belongs_to :sector

  # subjects
  belongs_to :headline
  belongs_to :organization
  belongs_to :redesign_container, class_name: "Redesign::Container"
  belongs_to :resource

  # TODO replace the existing principles join tables with implementations here
  # belongs_to :communication_on_progress
  # belongs_to :event

  def domain
    author || principle || country || initiative || language || sector || topic || issue
  end

  def subject
    headline ||organization ||redesign_container
  end

end
