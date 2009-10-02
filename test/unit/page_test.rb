require 'test_helper'

class PageTest < ActiveSupport::TestCase
  def latest_version(page=nil)
    page ||= @page
    page.versions(:reload).last
  end
  
  context "given a page" do
    setup do
      @page = create_page :content => "<p>This is my content.</p>", :approved => false
    end

    should "auto-create first version" do
      assert_equal 1, @page.versions.count
      assert_equal "<p>This is my content.</p>", @page.versions.first.content
    end
    
    context "with another version" do
      setup do
        @version2 = @page.new_version :content => "<p>Middle version.</p>", :approved => true
      end

      should "auto-increment version number" do
        assert_equal 2, @version2.version_number
      end

      should "find one active version, version2" do
        assert_equal @version2, @page.active_version
      end

      context "with three versions" do
        setup do
          @version1 = @page.versions.first
          @version3 = @version2.new_version :content => "<p>Latest version.</p>"
          @active   = Page.approved_for_path(@page.path)
        end

        should "find version1 for previous_version" do
          assert_equal @version1, @active.previous_version
        end
        
        should "find version3 for next_version" do
          assert_equal @version3, @active.next_version
        end
        
        should "find version2 for version1.next_version" do
          assert_equal @version2, @version1.next_version
        end
        
        should "find version2 for version3.previous_version" do
          assert_equal @version2, @version3.previous_version
        end
        
        should "find nil for version3.next_version" do
          assert_equal nil, @version3.next_version
        end
        
        should "find nil for version1.previous_version" do
          assert_equal nil, @version1.previous_version
        end
      end
    end
  end
  
end
