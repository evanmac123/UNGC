module TestPage
  class PublicCopDetail < Base

    def initialize(cop)
      @cop = cop
    end

    def path
      show_cops_path(@cop.differentiation_level_with_default, @cop.id)
    end

    def published_on
      result_items[1]
    end

    def time_period
      result_items[2]
    end

    def format
      case
      when @cop.type == 'ExpressCop'
        result_items[4]
      when @cop.cop_type == 'intermediate'
        result_items[4]
      when @cop.cop_type == 'advanced'
        result_items[5]
      else
        result_items[3]
      end
    end

    private

    def result_items
      all('.main-content-body dl dd ul li').map(&:text)
    end

  end
end
