class Academy::Course < ActiveRecord::Base
  include SalesforceRecordConcern

  validates :code, length: { maximum: 50 }
  validates :name, length: { maximum: 255 }
  validates :course_type, length: { maximum: 255 }
  validates :description, length: { maximum: 255 }
  validates :language, length: { maximum: 100 }

  def event_stream_name
    EventPublisherHooks.event_stream_name(self)
  end

end
