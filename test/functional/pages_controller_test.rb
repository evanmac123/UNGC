require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  context "given a simple tree and some content" do
    setup do
      create_simple_tree
      @content = create_approved_content(:path => @child2.href, :content => String.random)
      @home_page = create_approved_content(:path => @root.href, :content => String.random)
    end

    context "view action" do
      should "find home page" do
        get :view, :path => ['index.html']
        assert_equal @home_page, assigns(:page)
        assert_layout 'home'
        assert_response :success
      end
      
      should "find content via path" do
        get :view, :path => @content.to_path
        assert_equal @content, assigns(:page)
        assert_layout 'application'
        assert_response :success
      end
      
      should "issue a 404 when content not found" do
        get :view, :path => 'invalid/path/here.html'.split('/')
        assert_response 404
      end
    end
    
    context "decorate action" do
      setup do
        # TODO: should be an authorized user
        # Also: test that non-authorized user gets a 403
      end
      
      should "respond with 403 when not an XHR" do
        get :decorate, :path => @content.to_path
        assert_equal @content, assigns(:page)
        assert_response 403
      end

      should "find content via path" do
        xhr :get, :decorate, :path => @content.to_path
        assert_equal @content, assigns(:page)
        assert_response :success
        assert_select 'a.edit_content', 'Click to edit'
      end

      should "issue a 404 when content not found" do
        get :view, :path => 'invalid/path/here.html'.split('/')
        assert_response 404
      end
    end
  end
  
end
