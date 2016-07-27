module TestPage
  class CopExpressForm < Base

    def initialize(organization)
      @organization = organization
    end

    def path
      new_admin_organization_express_cop_path(@organization)
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
        match = path_and_query.match(/express_cops\/(\d+)/)
        if match
          cop = @organization.communication_on_progresses.find(match[1])
          transition_to ExpressCopDetail.new(cop)
        else
          raise "Expected successful form submittion to transition to the show page. Got #{path_and_query} instead."
        end
      end
    end

    def has_validation_errors?
      all('.field_with_errors').any?
    end

    def validation_errors
      Array.wrap(find('.flash.error').text)
    end

  end

end
