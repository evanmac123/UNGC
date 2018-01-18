require 'test_helper'

class NewsListFormTest < ActiveSupport::TestCase
  context 'search with sustainable development goals in params' do
    setup do
      @sdgs = 2.times.collect { create(:sustainable_development_goal) }
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

  [
    [nil, nil],
    ["", nil],
    [" ", nil],
    ["]", nil],
    ["junk", nil],
    [Date.current, Date.current],
    ["2017-01-01", Date.new(2017, 1, 1)]
  ].each do |(input, expected)|

    test "start_date with #{input}" do
      form = NewsListForm.new(start_date: input)
      assert_parses input, expected, form.start_date
    end

    test "end_date with #{input}" do
      form = NewsListForm.new(end_date: input)
      assert_parses input, expected, form.end_date
    end

  end

  private

  def assert_parses(input, expected, actual)
    if expected.nil?
      assert_nil actual, "Expected #{input.inspect} to convert to nil, but was #{actual.inspect}"
    else
      assert_equal expected, actual, "Expected #{input.inspect} to convert to #{expected.inspect} but was #{actual.inspect}"
    end
  end

end
