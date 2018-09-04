# frozen_string_literal: true

class Academy::Enrollment < ActiveRecord::Base
  include SalesforceRecordConcern

  belongs_to :contact
  belongs_to :course,
    class_name: "Academy::Course",
    foreign_key: "academy_course_id"

end
