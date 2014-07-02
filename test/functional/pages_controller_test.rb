require 'test_helper'

class PagesControllerTest < ActionController::TestCase

  def assert_blank_response
    assert_response :success
    assert_match /\A\s*\Z/, @response.body
  end

  def setup
    request.env['devise.mapping'] = Devise.mappings[:contact]
  end

  context "given a simple tree and some content" do
    setup do
      create_simple_tree
      @home_page = @root
      @page      = @child2
      # @page = create_page(:path => @child2.path, :content => FixtureReplacement.random_string)
      # @home_page = @root #create_page(:path => @root.path, :content => FixtureReplacement.random_string)
    end

    context "view action" do
      should "find home page" do
        get :view, :path => ['index.html']
        assert_equal @home_page, assigns(:page)
        assert_template 'layouts/home'
        assert_response :success
      end

      should "find content via path" do
        get :view, :path => @page.to_path
        assert_equal @page, assigns(:page)
        assert_template 'layouts/application'
        assert_response :success
      end

      should "issue a 404 when content not found" do
        get :view, :path => 'invalid/path/here.html'.split('/')
        assert_response 404
      end

      should "render using standard, static template" do
        get :view, :path => @page.to_path
        assert_template 'pages/static'
      end
    end

    context "decorate action" do
      context "when logged-in staff" do
        setup do
          sign_in create_staff_user
        end

        should "blank response when not an XHR" do
          get :decorate, :path => @page.to_path
          assert_blank_response
        end

        should "find content via path" do
          xhr :get, :decorate, {:path => @page.to_path}
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
            xhr :get, :decorate, {:path => @page.to_path, :version => @version2.version_number}
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
          sign_in create_organization_and_user
          get :decorate, {:path => @page.to_path}
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

  context "given several version of the index path" do

    setup do
      # to match a real bug, the first version will have dynamic_content == nil
      create_page(
        path:             '/index.html',
        content:          '<p>This is my page1.</p>',
        approval:         'previously',
        dynamic_content:  nil
      )

      # a 2nd page is approved
      @approved = create_page(
        path:             '/index.html',
        content:          '<p>This is my page2.</p>',
        approval:         'approved',
        dynamic_content:  true
      )
    end

    should "view the approved version" do
      get :view, :path => 'index.html'
      page = assigns(:page)

      assert_equal @approved.id, page.id
      assert page.approved?, 'expected page to be approved'
      assert page.dynamic_content?, 'expected page to be dynamic'
    end

    context "previewing a pending version" do
      setup do
        sign_in create_staff_user
        @preview_page = create_page(
          path:             '/index.html',
          content:          '<p>page4</p>',
          approval:         'pending',
          dynamic_content:  true
        )

        get :preview, :path => 'index.html'
        @rendered_page = assigns(:page)
      end

      should "preview the correct version" do
        assert_equal @preview_page.id, @rendered_page.id
      end

      should "be pending still" do
        refute @rendered_page.approved?
      end

      should "be dynamic" do
        assert @rendered_page.dynamic_content?
      end

    end

  end

  context "cache paths" do

    should 'cache the approved version at /index.html' do
      page = create_page(path: '/index.html', approval: 'approved')
      assert_equal '/index.html', page.cache_path
    end

    should 'cache the pending version at /index.html-pending' do
      page = create_page(path: '/index.html', approval: 'pending',)
      assert_equal '/index.html-pending', page.cache_path
    end

  end

end
