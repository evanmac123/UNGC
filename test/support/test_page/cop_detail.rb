module TestPage
  class CopDetail < Base

    def initialize(cop)
      @cop = cop
    end

    def path
      admin_organization_communication_on_progress_path(@cop.organization.id, @cop)
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

    def positive_assessment_items
      all('.self_assessment .selected_question').map(&:text)
    end

    def missing_assessment_items
      all('.self_assessment .unselected_question').map(&:text)
    end

    def references?(area)
      description = case area
      when :human_rights
        'Description of actions or relevant policies related to Human Rights'
      when :labour
        'Description of actions or relevant policies related to Labour'
      when :environment
        'Description of actions or relevant policies related to Environment'
      when :anti_corruption
        'Description of actions or relevant policies related to Anti-Corruption'

        check_assessment description
      end
    end

    def include_continued_support_statement?
      check_assessment 'Includes a CEO statement of continued support for the UN Global Compact and its ten principles'
    end

    def include_measurement?
      check_assessment 'Includes a measurement of outcomes'
    end

    def published_on
      result_items[0]
    end

    def time_period
      result_items[1]
    end

    def format
      case @cop.cop_type
      when 'basic' then result_items[2]
      when 'intermediate' then result_items[3]
      when 'advanced' then result_items[4]
      else
        raise "I don't know how to get the format for a #{@cop.cop_type} COP"
      end
    end

    private

    def result_items
      all('#results dl dd ul li').map(&:text)
    end

    def check_assessment(description)
      # check both collections
      in_positive = positive_assessment_items.include?(description)
      in_missing = missing_assessment_items.include?(description)

        # the item should be in one or the other
      if in_positive != in_missing
        in_positive
      else
        raise "there was a problem determining if the COP references #{area} or not"
      end
    end

  end
end
