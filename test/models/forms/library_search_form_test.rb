require 'test_helper'

class LibrarySearchFormTest < ActiveSupport::TestCase

  setup do
    # issues
    @issues = create_issue_hierarchy
    @selected_issue_area = @issues.first
    @selected_issue = @issues.last.children.last

    # topics
    @topics = create_topic_hierarchy
    @selected_topic_group = @topics.first
    @selected_topic = @topics.last.children.last

    # sectors
    @sectors = create_sector_hierarchy
    @selected_sector_group = @sectors.last
    @selected_sector = @sectors.first.children.last

    # languages
    @languages = ["English", "French"].map { |name| create(:language, name: name) }
    @selected_language = @languages.last

    # search params
    @search_params = search_params = {
      issue_areas:    [@selected_issue_area.id.to_s],
      issues:         [@selected_issue.id.to_s],
      topic_groups:   [@selected_topic_group.id.to_s],
      topics:         [@selected_topic.id.to_s],
      sector_groups:  [@selected_sector_group.id.to_s],
      sectors:        [@selected_sector.id.to_s],
      languages:      [@selected_language.id.to_s],
    }.deep_stringify_keys
  end

  should "maintain a list of active filters" do
    form = LibrarySearchForm.new 1, @search_params

    assert_equal [
      'issue_areas',
      'issues',
      'languages',
      'sector_groups',
      'sectors',
      'topic_groups',
      'topics',
    ], form.active_filters.map(&:type).sort

    assert_equal [
      @selected_issue.id,
      @selected_issue_area.id,
      @selected_language.id,
      @selected_sector.id,
      @selected_sector_group.id,
      @selected_topic.id,
      @selected_topic_group.id,
    ].sort, form.active_filters.map(&:id).sort
  end

  context "Issue selector options" do

    setup do
      @form = LibrarySearchForm.new 1, @search_params
      @form.search_scope = all_group_facets(@issues, :issue_ids)
      @options = @form.issue_filter.options

      @area = @options.last.first
      @filters = @options.last.last
    end

    should "have an issue area" do
      assert_equal "Issue B", @area.name
    end

    should "have a selected issue area" do
      issue_area_a = @options.first.first
      assert issue_area_a.selected?
    end

    should "have names" do
      assert_equal ["Issue 4", "Issue 5", "Issue 6"], @filters.map(&:name)
    end

    should "have match the issue's ids" do
      issue_b_child_ids = @issues.last.children.map(&:id)
      assert_equal issue_b_child_ids, @filters.map(&:id)
    end

    should "have issue type" do
      assert_equal ['issues'], @filters.map(&:type).uniq
    end

    should "have active states" do
      assert_equal [false, false, true], @filters.map(&:selected?)
    end

  end

  context "Topics selector options" do

    setup do
      @form = LibrarySearchForm.new 1, @search_params
      @form.search_scope = all_group_facets(@topics, :topic_ids)
      @options = @form.topic_filter.options

      @group = @options.last.first
      @filters = @options.last.last
    end

    should "have a topic group" do
      assert_equal "Topic B", @group.name
    end

    should "have a selected topic group" do
      topic_group_a = @options.first.first
      assert topic_group_a.selected?
    end

    should "have names" do
      assert_equal ["Topic 4", "Topic 5", "Topic 6"], @filters.map(&:name)
    end

    should "have match the topic's ids" do
      topic_b_child_ids = @topics.last.children.map(&:id)
      assert_equal topic_b_child_ids, @filters.map(&:id)
    end

    should "have topic type" do
      assert_equal ['topics'], @filters.map(&:type).uniq
    end

    should "have active states" do
      assert_equal [false, false, true], @filters.map(&:selected?)
    end

  end

  context "Language selector options" do

    setup do
      @form = LibrarySearchForm.new 1, @search_params
      @form.search_scope = FakeFacetResponse.with(:language_ids, @languages.map(&:id))
      @options = @form.language_filter.options
    end

    should "have all the languages" do
      expected = @languages.map &:id
      actual = @options.map &:id
      assert_equal expected, actual
    end

    should "have mark the selected one" do
      assert @options.last.selected?
    end

  end

  context 'search with sustainable development goals in params' do
    setup do
      @sdgs = 2.times.collect { create(:sustainable_development_goal) }
      @params = { sustainable_development_goals: [@sdgs.first.id] }.deep_stringify_keys

      @search = LibrarySearchForm.new 1, @params
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

  private

  def all_group_facets(items, key)
    ids = items.map do |item|
      [item.id, item.children.map(&:id)]
    end
    FakeFacetResponse.with(key, ids.flatten)
  end

end
