# == Schema Information
#
# Table name: taggings
#
#  id                              :integer          not null, primary key
#  author_id                       :integer
#  principle_id                    :integer
#  principle_type                  :string(255)
#  country_id                      :integer
#  initiative_id                   :integer
#  language_id                     :integer
#  sector_id                       :integer
#  communication_on_progress_id    :integer
#  event_id                        :integer
#  headline_id                     :integer
#  organization_id                 :integer
#  resource_id                     :integer
#  container_id                    :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  topic_id                        :integer
#  issue_id                        :integer
#  case_example_id                 :integer
#  sustainable_development_goal_id :integer
#

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
  belongs_to :sustainable_development_goal

  # subjects
  belongs_to :event
  belongs_to :headline
  belongs_to :organization
  belongs_to :container
  belongs_to :resource

  # TODO replace the existing principles join tables with implementations here
  # belongs_to :communication_on_progress

  def domain
    author || principle || country || initiative || language || sector || topic || issue || sustainable_development_goal
  end

  def subject
    event || headline || organization || container || resource
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
