class DueDiligence::ReviewRequest
  include ActiveModel::Model
  include Virtus.model

  attribute :organization_name, String
  attribute :level_of_engagement, Integer
  attribute :requester, Contact
  attribute :additional_information, String
  attribute :individual_subject, String
  attribute :event_title, String

  validates :organization_name, presence: true
  validates :level_of_engagement, presence: true
  validates :requester, presence: true
  validate :named_organization_exists, :named_event_exists

  def levels_of_engagement
    DueDiligence::Review.levels_of_engagement.map do |key, value|
      [key.titlecase, value]
    end
  end

  def create
    @new_review = DueDiligence::Review.new(
        organization: organization,
        level_of_engagement: (Integer(level_of_engagement) if level_of_engagement.present?),
        additional_information: additional_information,
        requester: requester,
        individual_subject: individual_subject,
        event: event
    )
  end

  private

  def organization
    @_organization ||= Organization.find_by(name: organization_name)
  end

  def named_organization_exists
    if organization.nil?
      errors.add :organization_name, 'is not the name of an existing organization'
    end
  end

  def event
    @_event ||= Event.find_by(title: event_title)
  end

  def named_event_exists
    if event.nil?
      errors.add :event_title, 'is not the title of an existing event'
    end
  end
end
