require 'test_helper'

class RoutingTest < ActionController::IntegrationTest

  context "Content routing" do
    setup do
      @page = create_page
    end

    should "find routes for editing content" do
      assert_routing "/admin/pages/#{@page.id}/edit", {:controller => 'admin/pages', :action => 'edit', :id => @page.id.to_s}
    end

    should "generate path to admin" do
      assert_equal "/admin/pages/#{@page.id}/edit", edit_page_path(:id => @page)
    end
  end

end
