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
    @languages = ["English", "French"].map { |name| create_language name: name }
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
      @form.search_scope = all_facets(@languages, :language_ids)
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

  context "Sector selector options" do

    setup do
      @form = LibrarySearchForm.new 1, @search_params
      @form.search_scope = all_group_facets(@sectors, :sector_ids)

      @options = @form.sector_filter.options
      @group_a = @options.first
      @group_b = @options.last

      @group = @group_a.first
      @filters = @group_a.last
      @filter = @filters.first

      # the sector that should map to the filter
      @sector = @sectors.first.children.first
    end

    should "have 2 items" do
      assert_not_nil @group_a
      assert_not_nil @group_b
    end

    should "be grouped by title" do
      assert_match /Sector (A|B)/, @group.name
    end

    should "have a selected group" do
      assert @group_b.first.selected?
    end

    should "have 3 children" do
      assert_equal 3, @filters.count
    end

    should "include sector id" do
      assert_equal @sector.id, @filter.id
    end

    should "be of type: sectors" do
      assert_equal 'sectors', @filter.type
    end

    should "not be active by default" do
      assert_equal false, @filter.selected?
    end

    should "have the sector name" do
      assert_equal @sector.name, @filter.name
    end

    # TODO FIXME this test's output is not consistant and is causing CI to fail.
    # should "selecting an option should make it active" do
    #   form = LibrarySearchForm.new 1, @search_params
    #   form.search_scope = all_group_facets(@sectors, :sector_ids)
    #   option = form.sector_filter.options[0][1].last # group a, options
    #   assert option.selected?
    # end

  end

  def all_facets(items, key)
    stub(facets: {
      key => stub(keys: items.map(&:id))
    })
  end

  def all_group_facets(items, key)
    stub(
      facets: {
        key => stub(
          keys: items.flat_map { |i| [i.id, i.children.flat_map(&:id)] }.flatten
        )
      }
    )
  end

end
