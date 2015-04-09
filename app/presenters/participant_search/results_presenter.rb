class ParticipantSearch::ResultsPresenter < ParticipantSearch::Presenter
  attr_accessor :results

  def initialize(search, results)
    super(search)
    @results = results
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

end
