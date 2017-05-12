class DueDiligence::Review::Presenter < SimpleDelegator

  def self.wrap(reviews)
    reviews.map do |review|
      new(review)
    end
  end

  def organization_name
    organization.name
  end

  def events
    event_store = RailsEventStore::Client.new
    stream_name = "due_diligence_review_#{self.id}"
    event_store.read_stream_events_forward(stream_name).map do |event|
      AuditLog.new(event)
    end
  end

  def state_o_meter
    StateOMeter.new(self)
  end

  def new_comment
    comments.build
  end

  def requester_name
    requester&.name
  end

  def level_of_engagement_title
    level_of_engagement.try(:titlecase)
  end

  def last_activity_date
    comments.last ? comments.last.created_at : created_at
  end

  def highest_controversy_level_class(level=self.highest_controversy_level)
    level ? "level_#{level.to_s}" : nil
  end

  class AuditLog
    def initialize(event)
      @event = event
    end

    def name
      @event.class.name.demodulize
    end

    def author
      id = @event.data[:requester_id] || @event.data[:contact_id]
      Contact.find_by(id: id).name || "Unknown"
    end

    def timestamp
      @event.metadata[:timestamp]
    end

  end

  class StateOMeter

    def initialize(review)
      @review = review
    end

    def each
      if block_given?
        current_step = @review.review_step_index
        DueDiligence::Review.review_steps.each_with_index do |step, index|
          yield(step, css_class_name(current_step, index))
        end
      end
    end

    private

    def css_class_name(current_step, step)
      if current_step >= step
        "active"
      else
        "inactive"
      end
    end

  end

end
