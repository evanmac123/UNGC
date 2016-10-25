require 'test_helper'

class IssueFilterTest < ActiveSupport::TestCase

  context "Effective selection set" do

    setup do
      @social = Issue.find_by!(name: "Social")
      @education = Issue.find_by!(name: "Education")

      @environment = Issue.find_by!(name: 'Environment')
      @energy = Issue.find_by!(name: 'Energy')

      # Filter down to Social with Education specifically selected
      # And Energy on it's own
      @filter = ::Filters::IssueFilter.new(
        [@social.id],
        [@education.id, @energy.id]
      )

      @set = @filter.effective_selection_set
    end

    should 'have selected the social parent' do
      assert_includes @set, @social.id
      assert_not_includes @set, @environment.id
    end

    should "have selected the parent's children" do
      # the set contains all of the children
      assert_empty @social.children.pluck(:id) - @set
    end

    should "have selected the individual child" do
      assert_includes @set, @education.id
      biodiversity = Issue.find_by!(name: "Biodiversity")
      assert_not_includes @set, biodiversity.id
    end

  end

end
