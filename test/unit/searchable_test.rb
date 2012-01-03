require 'test_helper'

class SearchableTest < ActiveSupport::TestCase
  context "given some pages that have already been indexed by searchable" do
    setup do
      @page1 = create_page
      @page2 = create_page
      @page3 = create_page title: 'Page 3 here'
      Searchable.index_pages
    end

    context "and changes are made" do
      setup do
        assert @prev_max = Searchable.find(:all, select: "MAX(last_indexed_at) as max").first.try(:max)
        sleep(2) { donothing = true; justwaiting = "for the timestamps to be sufficiently different" }
        @page4 = create_page title: 'Page 4 here'
        @page3.title = "I am new"
        @page3.save
      end

      should "only index new or updated pages" do
        Searchable.index_new_or_updated
        newish = Searchable.find(:all, conditions: ["last_indexed_at > ?", @prev_max])
        assert_same_elements [@page4.title, @page3.title], newish.map(&:title)
      end
    end


  end

end
