require 'test_helper'

class LibrarySearchFormTest < ActiveSupport::TestCase

  setup do
    # issues
    @issues = create_issue_hierarchy
    @selected_issue_area = @issues.first
    @selected_issue = @issues.last.issues.last

    # topics
    @topics = create_topic_hierarchy
    @select_topic_group = @topics.first
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
      issue_areas:    { @selected_issue_area.id     => "1" },
      issues:         { @selected_issue.id          => "1" },
      topic_groups:   { @select_topic_group.id      => "1" },
      topics:         { @selected_topic.id          => "1" },
      sector_groups:  { @selected_sector_group.id   => "1" },
      sectors:        { @selected_sector.id         => "1" },
      languages:      { @selected_language.id       => "1" }
    }.deep_stringify_keys
  end

  should "maintain a list of active filters" do
    form = Redesign::LibrarySearchForm.new 1, @search_params

    assert_equal [
      :issue_area,
      :issue,
      :topic_group,
      :topic,
      :language,
      :sector_group,
      :sector
    ], form.active_filters.map(&:type)

    assert_equal [
      @selected_issue_area.id,
      @selected_issue.id,
      @select_topic_group.id,
      @selected_topic.id,
      @selected_language.id,
      @selected_sector_group.id,
      @selected_sector.id
    ], form.active_filters.map(&:id)
  end

  context "Issue selector options" do

    setup do
      @form = Redesign::LibrarySearchForm.new 1, @search_params
      @options = @form.issue_options

      @area = @options.last.first
      @filters = @options.last.last
    end

    should "have an issue area" do
      assert_equal "Issue B", @area.name
    end

    should "have a selected issue area" do
      issue_area_a = @options.first.first
      assert issue_area_a.active
    end

    should "have names" do
      assert_equal ["Issue 4", "Issue 5", "Issue 6"], @filters.map(&:name)
    end

    should "have match the issue's ids" do
      issue_b_child_ids = @issues.last.issues.map(&:id)
      assert_equal issue_b_child_ids, @filters.map(&:id)
    end

    should "have issue type" do
      assert_equal [:issue], @filters.map(&:type).uniq
    end

    should "have active states" do
      assert_equal [false, false, true], @filters.map(&:active)
    end

  end

  context "Topics selector options" do

    setup do
      @form = Redesign::LibrarySearchForm.new 1, @search_params
      @options = @form.topic_options

      @group = @options.last.first
      @filters = @options.last.last
    end

    should "have a topic group" do
      assert_equal "Topic B", @group.name
    end

    should "have a selected topic group" do
      topic_group_a = @options.first.first
      assert topic_group_a.active
    end

    should "have names" do
      assert_equal ["Topic 4", "Topic 5", "Topic 6"], @filters.map(&:name)
    end

    should "have match the topic's ids" do
      topic_b_child_ids = @topics.last.children.map(&:id)
      assert_equal topic_b_child_ids, @filters.map(&:id)
    end

    should "have topic type" do
      assert_equal [:topic], @filters.map(&:type).uniq
    end

    should "have active states" do
      assert_equal [false, false, true], @filters.map(&:active)
    end

  end

  context "Language selector options" do

    setup do
      @form = Redesign::LibrarySearchForm.new 1, @search_params
    end

    should "have all the languages" do
      expected = @languages.map &:id
      actual = @form.language_options.map &:id
      assert_equal expected, actual
    end

    should "have mark the selected one" do
      assert @form.language_options.last.active
    end

  end

  context "Sector selector options" do

    setup do
      @form = Redesign::LibrarySearchForm.new 1, @search_params

      @options = @form.sector_options
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
      assert_equal "Sector A", @group.name
    end

    should "have a selected group" do
      assert @group_b.first.active
    end

    should "have 3 children" do
      assert_equal 3, @filters.count
    end

    should "include sector id" do
      assert_equal @sector.id, @filter.id
    end

    should "be of type: sector" do
      assert_equal :sector, @filter.type
    end

    should "not be active by default" do
      assert_equal false, @filter.active
    end

    should "have the sector name" do
      assert_equal @sector.name, @filter.name
    end

    should "selecting an option should make it active" do
      form = Redesign::LibrarySearchForm.new 1, @search_params
      filter = form.sector_options[0][1].last # group a, filters
      assert filter.active
    end

  end

  context "output" do
  end

end
