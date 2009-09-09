require 'test_helper'

class ContentVersionTest < ActiveSupport::TestCase
  context "given some content" do
    setup do
      @content = create_content :content => "<p>This is my content.</p>"
    end

    should "auto-create first version" do
      assert_equal 1, @content.versions.count
      assert_equal "<p>This is my content.</p>", @content.versions.first.content
    end
    
    context "with another version" do
      setup do
        @version2 = @content.versions.create :content => "<p>Middle version.</p>", :approved => true
      end

      should "auto-increment version number" do
        assert_equal 2, @version2.number
      end

      should "find one active version, version2" do
        assert_equal @version2, @content.active_version
      end

      context "with three versions" do
        setup do
          @version1 = @content.versions.first
          @version3 = @content.versions.create :content => "<p>Latest version.</p>"
        end

        should "find version1 for previous_version" do
          assert_equal @version1, @content.previous_version
        end
        
        should "find version3 for next_version" do
          assert_equal @version3, @content.next_version
        end
        
        should "find version2 for version1.next_version" do
          assert_equal @version2, @version1.next_version
        end
        
        should "find version2 for previous_version" do
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
