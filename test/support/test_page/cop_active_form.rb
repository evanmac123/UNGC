module TestPage
  class CopActiveForm < Base

    def initialize(organization)
      @organization = organization
    end

    def path
      new_admin_organization_communication_on_progress_path(
        @organization.id, type_of_cop: 'intermediate'
      )
    end

    def save_draft
      click_on 'Save Draft'
    end

    def select_format(value)
      choose value
    end

    def fill_in_title(title)
      fill_in 'communication_on_progress[title]', with: title
    end

    def select_start_date(month, year)
      select_date('starts_on', month, year)
    end

    def select_end_date(month, year)
      select_date('ends_on', month, year)
    end

    def check_continued_support_statement(value)
      choose "communication_on_progress_include_continued_support_statement_#{value}"
    end

    def check_reference(area, value)
      choose "communication_on_progress_references_#{area}_#{value}"
    end

    def check_include_measurement(value)
      choose "communication_on_progress_include_measurement_#{value}"
    end

    def choose_method_shared_with_stakeholders=(method)
      choose method
    end

    def submit
      click_on 'Submit'
      if has_validation_errors?
        self
      else
        match = current_path.match(/communication_on_progresses\/(\d+)/)
        if match
          cop = @organization.communication_on_progresses.find(match[1])
          transition_to CopDetail.new(cop)
        else
          raise "Expected successful form submittion to transition to the show page. Got #{path_and_query} instead."
        end
      end
    end

    def has_validation_errors?
      validation_errors.any?
    end

    def validation_errors
      all('.flash li').map(&:text)
    end

    def add_file(language:, filename:)
      select language, from: 'communication_on_progress_cop_files_attributes_0_language_id'

      filepath = File.absolute_path("./test/fixtures/files/#{filename}")
      attach_file('communication_on_progress_cop_files_attributes_0_attachment', filepath)
    end

    private

    def select_date(field, month, year)
      select month, from: "communication_on_progress[#{field}(2i)]"
      select year, from: "communication_on_progress[#{field}(1i)]"
    end

  end

end
