require 'test_helper'

class AllOurWorkFormTest < ActiveSupport::TestCase
  context 'search with sustainable development goals in params' do
    setup do
      @sdgs = 2.times.collect { create(:sustainable_development_goal) }
      @params = { sustainable_development_goals: [@sdgs.first.id] }.deep_stringify_keys

      facet_response = FakeFacetResponse.with(:sustainable_development_goal_ids, @sdgs.map(&:id))
      @search = AllOurWorkForm.new @params, rand(100), facet_response
    end

    context '#sustainable_development_goal_filter#options' do
      should 'return all sustainable development goal options' do
        assert_equal @sdgs.map(&:id), @search.sustainable_development_goal_filter.options.map(&:id)
      end
    end

    context '#sustainable_development_goal_filter#options#select(&:selected?)' do
      should 'equal the selected sustainable development goal' do
        assert_equal [@sdgs.first.id], @search.sustainable_development_goal_filter.options.select(&:selected?).map(&:id)
      end
    end
  end

  private

  def all_facets(items, key)
    facets = items.each_with_object({}) do |item, acc|
      acc[item.id] = 1
    end
    stub(facets: {key => facets})
  end
end
