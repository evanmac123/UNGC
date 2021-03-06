# frozen_string_literal: true

module Academy
  class CourseImporter

    def initialize(api: Docebo::Api.create, sync_with_crm: true)
      @api = api
      @sync_with_crm = sync_with_crm
    end

    def authenticate
      @api.authenticate
    end

    class CoursePager

      def initialize(api)
        @api = api
      end

      def each_course(&block)
        data = @api.list_courses.fetch("data")

        yield_next_page(data, &block)
      end

      private

      def yield_next_page(data, &block)
        items = data.fetch("items")
        puts "\nProcessing #{items.count} courses"
        items.each do |item|
          yield(item) if block_given?
        end

        cursor = data["cursor"]
        current_page = data["current_page"]
        total_page_count = data["total_page_count"]

        if current_page < total_page_count && cursor.present?
          # there's more data
          response = @api.list_courses(cursor: cursor, page: current_page + 1)
          yield_next_page(response.fetch("data"), &block)
        end
      end

    end

    class EnrollmentPager

      def initialize(api, report_id, page_size: 500)
        @api = api
        @report_id = report_id
        @page_size = page_size
        @processed = 0
      end

      def each_enrollment(&block)
        data = @api.get_report(@report_id, from: @processed, count: @page_size)

        yield_next_page(data, &block)
      end

      private

      def yield_next_page(data, &block)
        rows = data.fetch("rows")
        puts "\nProcessing #{rows.count} enrollments"
        rows.each do |item|
          yield(item) if block_given?
          @processed += 1
        end

        if rows.count == @page_size
          # we probably have more
          response = @api.get_report(@report_id, from: @processed, count: @page_size)
          if response.fetch("success")
            # we have more to process
            yield_next_page(response, &block)
          end
        end

      end

    end

    def import_courses
      puts "Importing courses"
      course_pager = CoursePager.new(@api)
      course_pager.each_course do |c|
        # find course if it exists
        id = c.fetch("id_course")
        course = Course.find_or_initialize_by(id: id)

        # copy the attributes over
        course.assign_attributes(
          code: c.fetch("code"),
          name: c.fetch("name"),
          course_type: c.fetch("course_type"),
          description: c.fetch("description")&.truncate(255),
          language: c.fetch("language"),
          updated_at: Time.zone.parse(c.fetch("date_last_updated")),
          revision: c.fetch("revision") { 1 },
        )

        stream = course.event_stream_name
        if course.new_record?
          # new record, create it in the database and send it to salesforce
          attributes = course.attributes
          event = DomainEvents::Academy::CourseImported.new(data: attributes)
          course.save!
          EventPublisher.publish(event, to: stream) if event.present?
          ::Crm::Academy::CourseSyncJob.perform_later('create', course) if @sync_with_crm
          print "+"
        else
          # existing record, see if anything changed
          if course.changes.any?
            changes = course.changes.dup
            # save the changes and send the update to salesforce
            event = DomainEvents::Academy::CourseUpdated.new(data: changes)
            course.save!
            EventPublisher.publish(event, to: stream)
            ::Crm::Academy::CourseSyncJob.perform_later('update', course, changes.to_json) if @sync_with_crm
            print "."
          end
        end

      end
    end

    def import_enrollments
      puts "Importing enrollments"
      report_info = @api.list_reports(name: "ReportForSync").first

      enrollment_pager = EnrollmentPager.new(@api, report_info.fetch("id_filter"))
      enrollment_pager.each_enrollment do |row|
        course = Course.find(row.fetch("course.course_internal_id"))

        # find the contact. Some early staff accounts have their email as their username
        username = row.fetch("user.userid")
        contact = ::Contact.find_by("username = ? or email = ?", username, username)
        if contact.nil?
          Rails.logger.warn("Couldn't find contact for enrollment: #{username}")
          next
        end

        enrollment = Enrollment.find_or_initialize_by(
          course: course, contact: contact)

        enrollment.assign_attributes(
          first_access: row["enrollment.date_first_access"],
          last_access: row["enrollment.date_last_accesss"],
          completed_at: row["enrollment.date_complete"],
          time_in_course: parse_seconds(row["enrollment.total_time_in_course"]),
          status: row["enrollment.status"], # == row["level"]
          user_type: row["enrollment.level"], # == row["status"]
          timezone: "UTC",
          user_id: username,
          score: row["enrollment.score_given"],
          completion_percentage: parse_percentage(
            row["enrollment.course_completion_percentage"]),
        )

        enrollment.created_at ||= row["enrollment.date_inscr"]

        stream = "contact_#{contact.id}"
        if enrollment.new_record?
          # new record, create it in the database and send it to salesforce
          enrollment.save!
          attributes = enrollment.attributes
          event = DomainEvents::Academy::ContactEnrolledInCourse.new(data: attributes)
          EventPublisher.publish(event, to: stream) if event.present?
          ::Crm::Academy::EnrollmentSyncJob.perform_later('create', enrollment) if @sync_with_crm
          print "+"
        else
          # existing record, see if anything changed
          changes = enrollment.changes.dup
          if changes.any?
            # save the changes and send the update to salesforce
            event = DomainEvents::Academy::EnrollmentUpdated.new(data: changes)
            enrollment.save!
            EventPublisher.publish(event, to: stream)
            ::Crm::Academy::EnrollmentSyncJob.perform_later('update', enrollment, changes.to_json) if @sync_with_crm
            print "."
          end
        end

      end
    end

    private

    def parse_seconds(input)
      # 0s
      # 26s
      # 1h 6m
      # 0h 6m
      pattern = /((?<v>\d+)(?<u>\D{1}))/
      matches = input.scan(pattern)
      raise "Failed to parse time: #{input}" if matches.empty?

      matches.reduce(0) do |seconds, (value, unit)|
        case unit
        when "s"
          seconds += value.to_i
        when "m"
          seconds += value.to_i * 60
        when "h"
          seconds += value.to_i * 60 * 60
        else
          raise "Unexpected unit: #{unit} in #{input}"
        end
      end
    end

    def parse_percentage(input)
      input.gsub("%", "").to_f
    end

  end
end
