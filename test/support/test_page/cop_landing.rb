module TestPage
  class CopLanding < Base

    def initialize(organization)
      @organization = organization
    end

    def new_basic_cop
      click_on 'Submit a Basic COP here'
      transition_to CopBasicForm.new(@organization)
    end

    def new_active_cop
      click_on 'Submit a GC Active COP here'
      transition_to CopActiveForm.new(@organization)
    end

    def new_advanced_cop
      click_on 'Submit a GC Advanced COP here'
      transition_to CopAdvancedForm.new(@organization)
    end

    def new_reporting_cycle_adjustment
      click_on 'Submit a Reporting Cycle Adjustment here'
      transition_to ReportingCycleAdjustmentForm.new(@organization)
    end

    def new_grace_letter
      click_on 'Submit a New Grace Letter here'
      transition_to GraceLetterForm.new(@organization)
    end

    def new_express_cop
      click_on 'Submit an Express COP here'
      transition_to CopExpressForm.new(@organization)
    end

    def path
      '/admin/cops/introduction'
    end

  end
end
