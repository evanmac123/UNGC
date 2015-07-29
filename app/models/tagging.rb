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
  belongs_to :container
  belongs_to :resource

  # TODO replace the existing principles join tables with implementations here
  # belongs_to :communication_on_progress
  # belongs_to :event

  def domain
    author || principle || country || initiative || language || sector || topic || issue
  end

  def subject
    headline || organization || container || resource
  end

  def content
    # for the moment, author is the only model that doesn't respond to .name
    # this will stand until that changes
    case
    when domain.respond_to?(:name)
      domain.name
    when domain.respond_to?(:full_name)
      domain.full_name
    else
      raise "Can't extract content from #{domain.class} #{domain.id}"
    end
  end

end
