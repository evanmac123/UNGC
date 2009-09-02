require 'test_helper'

class RoutingTest < ActionController::IntegrationTest

  context "Content routing" do
    setup do
      @content = create_content
    end

    should "find routes for editing content" do
      assert_routing "/admin/content/#{@content.id}/edit", {:controller => 'admin/content', :action => 'edit', :id => @content.id.to_s}
    end
    
    should "generate path to admin" do
      assert_equal "/admin/content/#{@content.id}/edit", edit_content_path(:id => @content)
    end
  end
  
end
