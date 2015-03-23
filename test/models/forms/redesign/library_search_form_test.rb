require 'test_helper'

class LibrarySearchFormTest < ActiveSupport::TestCase

  setup do
    # topics
    @topics = create_topic_hierarchy
    @selected_topic = @topics.last.children.last

    # languages
    @languages = ["English", "French"].map { |name| create_language name: name }
    @selected_language = @languages.last

    # sectors
    @sectors = ["Sectors a", "Sectors b"].map do |group|
      parent = create_sector name: group
      3.times.map do |i|
        create_sector(
          name: "Child #{i}",
          parent: parent,
          icb_number: i
        )
      end
    end
    @selected_sector = @sectors.first.last

    # search params
    @search_params = search_params = {
      topics:     { @selected_topic.id    => "1" },
      sectors:    { @selected_sector.id   => "1" },
      languages:  { @selected_language.id => "1" }
    }.deep_stringify_keys
  end

  should "maintain a list of active filters" do
    form = Redesign::LibrarySearchForm.new 1, @search_params

    assert_equal [
      :topic,
      :language,
      :sector
    ], form.active_filters.map(&:type)

    assert_equal [
      @selected_topic.id,
      @selected_language.id,
      @selected_sector.id
    ], form.active_filters.map(&:id)
  end

  context "Issue selector options" do

    setup do
      @form = Redesign::LibrarySearchForm.new 1, @search_params
      @options = @form.topic_options

      @group_name = @options.last.first
      @filters = @options.last.last
    end

    should "have a group name" do
      assert_equal "Topic B", @group_name
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

  context "Topic selector options" do
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
      @form = Redesign::LibrarySearchForm.new

      @options = @form.sector_options
      @group_a = @options.first
      @group_b = @options.last

      @group_name = @group_a.first
      @filters = @group_a.last
      @filter = @filters[2]

      # the sector that should map to the filter
      @sector = @sectors[0][2]
    end

    should "have 2 items" do
      assert_not_nil @group_a
      assert_not_nil @group_b
    end

    should "be grouped by title" do
      assert_equal "Sectors a", @group_name
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
