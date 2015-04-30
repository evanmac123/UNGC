class ParticipantSearch::ResultsPresenter
  attr_accessor :results, :raw_results

  def initialize(results)
    @raw_results = results
    @results = results.map {|r| Result.new(r) }
  end

  def with_results(&block)
    if results.any?
      block.call(results)
    end
  end

  def no_results(&block)
    if results.empty?
      block.call
    end
  end

  private

  class Result < SimpleDelegator

    def type
      organization.organization_type.name
    end

    def sector
      organization.sector.name
    end

    def country
      organization.country.name
    end

    def company_size
      organization.employees
    end

    private

    def organization
      __getobj__
    end

  end

end
