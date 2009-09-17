require 'test_helper'

class ContentTest < ActiveSupport::TestCase
  def latest_version(content=nil)
    content ||= @content
    content.versions(:reload).last
  end

  context "given some content" do
    setup do
      @template = create_content_template
      @content = create_content :template => @template
      @version1 = latest_version
    end

    context "when new version created" do
      setup do
        @content.new_version(:content => "Yo, I'm new.")
        @version2 = latest_version
      end

      should "save new version with same template" do
        assert_equal @template, @version2.template
      end
    end
  
    context "when new version created with new template" do
      setup do
        @template2 = create_content_template
        @content.new_version(:content => "Yo, I'm even newer", :template => @template2)
        @version2 = latest_version
      end

      should "have template2 for version2" do
        assert_equal @template2, @version2.template
      end
    end
  end
end
