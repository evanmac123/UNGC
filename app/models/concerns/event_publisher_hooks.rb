# frozen_string_literal: true

module EventPublisherHooks
  extend ActiveSupport::Concern

  included do
    after_commit :event_stream_after_create_commit, on: :create
    after_commit :event_stream_after_update_commit, on: :update
    after_commit :event_stream_after_destroy_commit, on: :destroy
    after_save :event_stream_accumulate_changes
  end

  def event_stream_name
    "#{self.class.name.downcase}_#{id}"
  end

  private

  def event_stream_after_create_commit
    event_class = "DomainEvents::#{self.class.name}Created".constantize
    event_stream_publish_change_event(:create, event_class)
  end

  def event_stream_after_update_commit
    event_class = "DomainEvents::#{self.class.name}Updated".constantize
    event_stream_publish_change_event(:update, event_class)
  end

  def event_stream_after_destroy_commit
    event_class = "DomainEvents::#{self.class.name}Destroyed".constantize
    data = HashWithIndifferentAccess.new(
      id: id,
      caller: local_call_stack
    )

    event = event_class.new(data: data)
    EventPublisher.publish(event, to: event_stream_name)
  end

  def event_stream_accumulate_changes
    @_event_stream_changes ||= HashWithIndifferentAccess.new

    changes.each do |k, v|
      @_event_stream_changes[k] = v.last
    end
  end

  def event_stream_publish_change_event(action, event_class)
    # reset transaction_changes, and keep the hash of changes
    @_event_stream_changes, changes_from_tx = HashWithIndifferentAccess.new, @_event_stream_changes

    return if changes_from_tx.blank?

    changes = changes_from_tx.except(*job_class.excluded_attributes)

    event = event_class.new(data: {
      changes: changes,
      caller: local_call_stack
    })
    EventPublisher.publish(event, to: event_stream_name)
  end

  def local_call_stack
    this_file = Regexp.new(File.basename(__FILE__))
    pattern = Regexp.new(Rails.root.to_s)
    caller.select do |line|
      line =~ pattern
    end.map do |line|
      line.gsub(Rails.root.to_s+"/", "")
    end.reject do |line|
      line =~ this_file
    end.lazy.to_a
  end

end
