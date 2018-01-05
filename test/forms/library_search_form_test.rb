require 'test_helper'

class LibrarySearchFormTest < ActiveSupport::TestCase

  setup do
    @language = Language.french

    @issue_area = find_issue("Social")
    @issue = find_issue("Education")

    @topic_group = find_topic("Financial Markets")
    @topic = find_topic("Social Enterprise")

    @sector_group = find_sector("Retail")
    @sector = find_sector("Tobacco")

    # search params
    @search_params = {
      issue_areas:    [@issue_area.id.to_s],
      issues:         [@issue.id.to_s],
      topic_groups:   [@topic_group.id.to_s],
      topics:         [@topic.id.to_s],
      sector_groups:  [@sector_group.id.to_s],
      sectors:        [@sector.id.to_s],
      languages:      [@language.id.to_s],
    }.deep_stringify_keys
  end

  test "maintain a list of active filters" do
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
      @issue.id,
      @issue_area.id,
      @language.id,
      @sector.id,
      @sector_group.id,
      @topic.id,
      @topic_group.id,
    ].sort, form.active_filters.map(&:id).sort
  end

  context "Issue selector options" do

    setup do
      @form = LibrarySearchForm.new 1, @search_params
      @form.search_scope = FakeFacetResponse.with(:issue_ids, Issue.pluck(:id))
      @options = @form.issue_filter.options

      @area = @options.first.first
      @filters = @options.first.last
    end

    should "have an issue area" do
      assert_equal "Social", @area.name
    end

    should "have a selected issue area" do
      assert @area.selected?
    end

    should "have names" do
      expected = [
        "Principle 1",
        "Principle 2 ",
        "Principle 3",
        "Principle 4 ",
        "Principle 5 ",
        "Principle 6",
        "Child Labour",
        "Children's Rights",
        "Education",
        "Forced Labour",
        "Health",
        "Human Rights",
        "Human Trafficking",
        "Indigenous Peoples",
        "Labour",
        "Migrant Workers",
        "Persons with Disabilities",
        "Poverty",
        "Gender Equality",
        "Women's Empowerment",
        "Youth"
      ]
      assert_equal expected, @filters.map(&:name)
    end

    should "have match the issue's ids" do
      child_ids = @issue_area.children.pluck(:id)
      assert_equal child_ids, @filters.map(&:id)
    end

    should "have issue type" do
      assert_equal ['issues'], @filters.map(&:type).uniq
    end

    should "have active states" do
      expected = [
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        true,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false
      ]
      assert_equal expected, @filters.map(&:selected?)
    end

  end

  context "Topics selector options" do

    setup do
      @form = LibrarySearchForm.new 1, @search_params
      @form.search_scope = FakeFacetResponse.with(:topic_ids, Topic.pluck(:id))
      @options = @form.topic_filter.options

      @group = @options.first.first # Financial Markets
      @filters = @options[2][1]     # UN-Business Partnerships, Social Enterprise
    end

    should "have a topic group" do
      assert_equal "Financial Markets", @group.name
    end

    should "have a selected topic group" do
      assert @group.selected?
    end

    should "have names" do
      expected = ["UN-Business Partnerships", "Social Enterprise"]
      assert_equal expected, @filters.map(&:name)
    end

    should "have match the topic's ids" do
      partnerships = Topic.find_by!(name: "Partnerships")
      child_ids = partnerships.children.pluck(:id)
      assert_equal child_ids, @filters.map(&:id)
    end

    should "have topic type" do
      assert_equal ['topics'], @filters.map(&:type).uniq
    end

    should "have active states" do
      assert_equal [false, true], @filters.map(&:selected?)
    end

  end

  context "Language selector options" do

    setup do
      @form = LibrarySearchForm.new 1, @search_params
      @form.search_scope = FakeFacetResponse.with(:language_ids, Language.pluck(:id))
      @options = @form.language_filter.options
    end

    should "have all the languages" do
      expected = Language.pluck(:id)
      actual = @options.map(&:id)
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

  def find_issue(name)
    Issue.find_by!(name: name)
  end

  def find_topic(name)
    Topic.find_by!(name: name)
  end

  def find_sector(name)
    Sector.find_by!(name: name)
  end

end
