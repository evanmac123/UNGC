class DueDiligence::ReviewRequest
  include ActiveModel::Model
  include Virtus.model

  attribute :organization_name, String
  attribute :event_title, String
  attribute :level_of_engagement, Integer
  attribute :requester, Contact
  attribute :additional_information, String
  attribute :individual_subject, String

  validates :organization_name, presence: true
  validates :level_of_engagement, presence: true
  validates :requester, presence: true
  validate :named_organization_exists, :named_event_exists

  attr_accessor :review

  def self.from(review)
    attrs = review.attributes.slice(
      'level_of_engagement',
      'requester',
      'additional_information',
      'individual_subject',
    ).with_indifferent_access

    review_request = new(attrs)
    review_request.organization_name = review.organization&.name
    review_request.event_title = review.event&.title
    review_request.review = review
    review_request
  end

  def levels_of_engagement
    DueDiligence::Review.levels_of_engagement.map do |key, value|
      [key.titlecase, value]
    end
  end

  def create(as:)
    contact = as
    if valid?
      @review = DueDiligence::Review.new(review_attributes)
      changes = @review.changes # must be called before persisting!

      DueDiligence::Review.transaction do
        @review.send_to_review!(contact)
        publish_change_event(changes, contact)
      end

      true
    else
      false
    end
  rescue ActiveRecord::RecordInvalid, StateMachine::InvalidTransition => e
    Rails.logger.error(e)
    false
  end

  def update(new_attributes)
    self.attributes = new_attributes
    if valid?
      DueDiligence::Review.transaction do
        @review.attributes = review_attributes
        publish_change_event(@review.changes, @review.requester)
        @review.save!
      end
      true
    else
      false
    end
  rescue ActiveRecord::RecordInvalid, StateMachine::InvalidTransition => e
    Rails.logger.error(e)
    false
  end

  def error_messages
    # combine form errors with any errors on the model
    model_error_messages = @review&.errors&.full_messages || []
    errors.full_messages + model_error_messages
  end

  private

  def review_attributes
    {
      organization: organization,
      level_of_engagement: (Integer(level_of_engagement) if level_of_engagement.present?),
      additional_information: additional_information,
      requester: requester,
      individual_subject: individual_subject,
      event: event
    }
  end

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
    if event_title.present? && event.nil?
      errors.add :event_title, 'is not the title of an existing event'
    end
  end

  def publish_change_event(changes, contact)
    # convert { key: ["previous_value", "new_value"] } ==> { key: "new_value" }
    changes_payload = changes.merge(changes) { |_k, val| val[1] }

    event = DueDiligence::Events::InfoAdded.new(data: {
      requester_id: contact.id,
      changes: changes_payload.to_h # changes_payload is a Params object, so we convert
    })

    stream_name = "due_diligence_review_#{@review.id}"
    event_store.publish_event(event, stream_name: stream_name)
  end

  def event_store
    @_client ||= RailsEventStore::Client.new
  end

end
