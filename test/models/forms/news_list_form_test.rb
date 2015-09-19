require 'test_helper'

class NewsListFormTest < ActiveSupport::TestCase
  context 'search with sustainable development goals in params' do
    setup do
      @sdgs = 2.times.collect { create_sustainable_development_goal }
      @params = { sustainable_development_goals: [@sdgs.first.id] }.deep_stringify_keys

      @search = NewsListForm.new @params
      @search.search_scope = FakeFacetResponse.with(:sustainable_development_goal_ids, @sdgs.map(&:id))
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

end
