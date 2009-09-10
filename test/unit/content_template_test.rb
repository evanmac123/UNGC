require 'test_helper'

class ContentTemplateTest < ActiveSupport::TestCase
  context "given two templates" do
    setup do
      @default = create_content_template :default => true
      @other   = create_content_template
    end

    should "find default template" do
      assert_equal @default, ContentTemplate.default
    end
  end
end
