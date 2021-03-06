require 'test_helper'

class ParticipantSearchPresenterTest < ActiveSupport::TestCase

  context "when no results are returned" do

    should "call the no_results block" do
      presenter = create_presenter(results: [])
      block = -> {}
      block.expects(:call)
      presenter.no_results(&block)
    end

  end

  context "when there are results" do

    should "iterate over the results" do
      type = create(:organization_type, name: 'type')
      organization = build(:organization, 
        name: 'name',
        organization_type: type,
        sector: build(:sector, name: 'sector'),
        country: build(:country, name: 'country'),
        employees: 23
      )

      presenter = create_presenter(results: [organization])

      output = []
      block = -> (results) {
        results.each do |result|
          output << result.name
          output << result.type
          output << result.sector
          output << result.country
          output << result.company_size
        end
      }
      presenter.with_results(&block)

      assert_equal ['name','type','sector','country', 23], output
    end

  end

  private

  def assert_options(collection, are_named: [])
    assert_equal are_named, collection.map(&:first)
  end

  def create_presenter(results: nil)
    results ||= stub()
    ParticipantSearch::ResultsPresenter.new(results)
  end

end
