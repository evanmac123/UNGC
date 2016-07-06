module TestPage
  class CopLanding < Base

    def initialize(organization)
      @organization = organization
    end

    def new_advanced_cop
      click_on 'Submit a GC Advanced COP here'
      transition_to CopAdvancedForm.new(@organization)
    end

    def path
      '/admin/cops/introduction'
    end

  end
end
