require 'test_helper'

class WhatYouCanDoFormTest < ActiveSupport::TestCase
  context 'search with sustainable development goals in params' do
    setup do
      @sdgs = 2.times.collect { create_sustainable_development_goal }
      input_params = { sustainable_development_goals: [@sdgs.first.id] }.deep_stringify_keys
      seed = rand(100)
      facet_response = FakeFacetResponse.with(:sustainable_development_goal_ids, @sdgs.map(&:id))

      @search = WhatYouCanDoForm.new(input_params, seed, facet_response)
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
