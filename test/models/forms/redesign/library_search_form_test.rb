require 'test_helper'

class LibrarySearchFormTest < ActiveSupport::TestCase

  setup do

  end

  should "maintain a list of active filters" do

  end

  context "Issue selector options" do

  end

  context "Topic selector options" do
  end

  context "Language selector options" do
  end

  context "Sector selector options" do

    setup do
      @form = Redesign::LibrarySearchForm.new
      @sectors = ["Group a", "Group b"].map do |group|
        parent = create_sector name: group
        3.times.map do |i|
          create_sector(
            name: "Child #{i}",
            parent: parent,
            icb_number: i
          )
        end
      end

      @options = @form.sector_options
      @group_a = @options.first
      @group_b = @options.last

      @group_name = @group_a.first
      @filters = @group_a.last
      @filter = @filters[1]

      # the sector that should map to the filter
      @sector = @sectors[0][1]
    end

    should "have 2 items" do
      assert_not_nil @group_a
      assert_not_nil @group_b
    end

    should "be grouped by title" do
      assert_equal "Group a", @group_name
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
      search_params = {"sectors" => {
        @sector.id.to_s => "1"
      }}

      form = Redesign::LibrarySearchForm.new 1, search_params
      filter = form.sector_options[0][1][1]
      assert filter.active
    end

  end

  context "output" do
  end

end
