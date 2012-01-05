require 'test_helper'

class PagesControllerTest < ActionController::TestCase

  def assert_blank_response
    assert_response :success
    assert_match /\A\s*\Z/, @response.body
  end

  context "given a simple tree and some content" do
    setup do
      create_simple_tree
      @home_page = @root
      @page      = @child2
      # @page = create_page(:path => @child2.path, :content => String.random)
      # @home_page = @root #create_page(:path => @root.path, :content => String.random)
    end

    context "view action" do
      should "find home page" do
        get :view, :path => ['index.html']
        assert_equal @home_page, assigns(:page)
        assert_layout 'home'
        assert_response :success
      end

      should "find content via path" do
        get :view, :path => @page.to_path
        assert_equal @page, assigns(:page)
        assert_layout 'application'
        assert_response :success
      end

      should "issue a 404 when content not found" do
        get :view, :path => 'invalid/path/here.html'.split('/')
        assert_response 404
      end

      should "render using standard, static template" do
        get :view, :path => @page.to_path
        assert_template 'pages/static.html.haml'
      end
    end

    context "decorate action" do
      context "when logged-in staff" do
        setup do
          @user = create_staff_user
        end

        should "blank response when not an XHR" do
          get :decorate, :path => @page.to_path
          assert_blank_response
        end

        should "find content via path" do
          xhr :get, :decorate, {:path => @page.to_path}, {:user_id => @user.id}
          assert_equal @page, assigns(:page)
          assert_response :success

          assert json = ActiveSupport::JSON.decode(@response.body)
          editor = json['editor']
          assert_match />Click to edit<\/a>/, editor
        end

        should "issue a 404 when content not found" do
          get :view, :path => 'invalid/path/here.html'.split('/')
          assert_response 404
        end

        context "when requesting with specific version" do
          setup do
            @version2 = @page.new_version :content => "<p>I am new here.</p>"
            xhr :get, :decorate, {:path => @page.to_path, :version => @version2.version_number}, {:user_id => @user.id}
          end

          should "find content via path" do
            assert_response :success
            assert json = ActiveSupport::JSON.decode(@response.body)
            content = json['content']
            assert_match "<p>I am new here.</p>", content
          end
        end
      end

      context "when logged-in but not staff" do
        setup do
          @user = create_organization_and_user
          get :decorate, {:path => @page.to_path}, {:user_id => @user.id}
        end

        should "get blank response" do
          assert_blank_response
        end
      end

      context "when not logged-in" do
        should "get blank response" do
          get :decorate, {:path => @page.to_path}
          assert_blank_response
        end
      end

    end
  end
end
