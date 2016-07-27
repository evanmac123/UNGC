module TestPage
  class ExpressCopDetail  < Base

    def initialize(cop)
      @cop = cop
    end

    def path
      admin_express_cop_path(@cop)
    end

    def click_on_public_version
      click_on 'Public version'
      transition_to PublicCopDetail.new(@cop)
    end

    def has_published_notice?
      has_content?('The communication has been published on the Global Compact website')
    end

    def platform
      find('#differentiation h3 span[style=""]').text.gsub('►', '').chop
    end

    def published_on
      result_items[0]
    end

    #what goes here?
    def format
      result_items[1]
    end

    def references_express?(area)
      description = case area
      when :covers_issue_areas
        'Action is taken in the areas of human rights, labour, environment and anti-corruption.'
      when :endorses_ten_principles
        'Highest executive supports and endorses the Ten Principles of the United Nations Global Compact.'
      when :measures_outcomes
        'Outcomes of such activities are monitored.'
      end
      check_express_assessment description
    end

    private

    def result_items
      all('#results dl dd ul li').map(&:text)
    end

    def check_express_assessment(description)
      items = all('#results .self_assessment .selected_question').map(&:text)
      items.include?(description)
    end

  end
end
