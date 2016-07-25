module TestPage
  class ReportingCycleAdjustmentForm < Base

    def initialize(organization)
      @organization = organization
    end

    def path
      new_admin_organization_reporting_cycle_adjustment_path(@organization.id)
    end

    def select_ends_on(month, day, year)
      select year, from: 'reporting_cycle_adjustment[ends_on(1i)]'
      select month, from: 'reporting_cycle_adjustment[ends_on(2i)]'
      select day, from: 'reporting_cycle_adjustment[ends_on(3i)]'
    end

    def select_language(language)
      select language, from: 'reporting_cycle_adjustment[language_id]'
    end

    def choose_letter(filename)
      path = File.absolute_path(File.join(['.', 'test', 'fixtures', 'files', filename]))
      attach_file('reporting_cycle_adjustment[attachment]', path)
    end

    def submit
      click_on 'Submit'
    end

    def validation_errors
      all('#errorExplanation li').map(&:text)
    end

    def flash_text
      find('.flash').text
    end

  end
end
