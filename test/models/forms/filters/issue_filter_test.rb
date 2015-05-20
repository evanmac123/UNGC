require 'test_helper'

class IssueFilterTest < ActiveSupport::TestCase

  context "Effective selection set" do

    setup do
      @issue_tree = create_issue_hierarchy

      @issue_a, @issue_b = @issue_tree
      @issue_1, @issue_2, @issue_3 = @issue_a.children
      @issue_4, @issue_5, @issue_6 = @issue_b.children

      selected_parents = [@issue_a.id]
      selected_children = [@issue_2.id, @issue_6.id]
      @filter = ::Filters::IssueFilter.new(selected_parents, selected_children)

      @set = @filter.effective_selection_set
    end

    should 'have selected the parent' do
      assert_includes @set, @issue_a.id
      assert_not_includes @set, @issue_b.id
    end

    should "have selected the parent's children" do
      assert_includes @set, @issue_1.id
      assert_includes @set, @issue_2.id
      assert_includes @set, @issue_3.id
    end

    should "have selected the individual child" do
          assert_includes @set, @issue_1.id
      assert_not_includes @set, @issue_4.id
      assert_not_includes @set, @issue_5.id
      assert_includes @set, @issue_6.id
    end

  end

end
