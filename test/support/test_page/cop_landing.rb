module TestPage
  class CopLanding < Base

    def new_advanced_cop
      click_on 'Submit a GC Advanced COP here'
      CopAdvancedForm.new
    end

  end
end
