module TestPage
  class CopExpressForm < Base

    def initialize(organization)
      @organization = organization
    end

    def path
      new_admin_organization_communication_on_progress_path(
        @organization.id, type_of_cop: 'express'
      )
    end

    def check_continued_support_statement(value)
      choose "express_cop_endorses_ten_principles_#{value}"
    end

    def check_covers_issue_areas(value)
      choose "express_cop_covers_issue_areas_#{value}"
    end

    def check_include_measurement(value)
      choose "express_cop_measures_outcomes_#{value}"
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

  end

end
