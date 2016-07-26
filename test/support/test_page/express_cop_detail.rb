module TestPage
  class ExpressCopDetail  < CopDetail

    def path
      admin_express_cop_path(@cop)
    end

    def references_express?(area)
      description = case area
      when :covers_issue_areas
        'Did your company take any actions in the areas of human rights, labour, environment and anti-corruption?'
      when :endorses_ten_principles
        'Does your company’s highest executive support and endorse the Ten Principles of the United Nations Global Compact?'
      when :measures_outcomes
        'Did your company monitor the outcomes of such activities?'
      end
      check_express_assessment description
    end

    def express_include_continued_support_statement?
      check_express_assessment 'Includes a CEO statement of continued support for the UN Global Compact and its ten principles'
    end

    def express_include_measurement?
      check_express_assessment 'Includes a measurement of outcomes'
    end
    


    private

    def check_express_assessment(description)
      positive_assessment_items.include?(description)
    end

  end
end
