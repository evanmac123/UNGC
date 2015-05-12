class ParticipantSearch::ResultsPresenter < SimpleDelegator

  def initialize(results)
    super(results)
  end

  def with_results(&block)
    if results.any?
      block.call(results.map {|r| Result.new(r) })
    end
  end

  def no_results(&block)
    if results.empty?
      block.call
    end
  end

  private

  def results
    __getobj__
  end

  class Result < SimpleDelegator

    def type
      organization.organization_type.name
    end

    def sector
      organization.sector.try(:name)
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
