require 'test_helper'

class Admin::PagesControllerTest < ActionController::TestCase
  context "given a page" do
    setup do
      @staff_user = create_staff_user
      @page = create_approved_page :path => '/path/to/page.html', :content => "<p>This is my page.</p>"
    end

    context "successful edit action" do
      setup do
        # TODO: should be a staff user
        xhr :get, :edit, {:id => @page.id}, as(@staff_user)
      end

      should "find page by id" do
        assert_equal @page, assigns(:page)
        assert_response :success
      end

      should "respond with JSON" do
        json = ActiveSupport::JSON.decode @response.body
        assert_same_elements %w{url content startupMode}, json.keys
        assert_same_elements [
          update_page_url(:id => @page.id, :format => 'js'),
          'wysiwyg',
          @page.content
        ], json.values
      end
    end

    context "edit a specific version" do
      setup do
        @version = @page.new_version :content => "<p>I am new.</p>"
        xhr :get, :edit, {:id => @page.id, :version => @version.version_number}, as(@staff_user)
      end

      should "respond with that version's contents" do
        json = ActiveSupport::JSON.decode @response.body
        content = json['content']
        assert_equal "<p>I am new.</p>", content
      end
    end

    context "bad edit action" do
      should "issue a 404 when page not found" do
        xhr :get, :edit, {:id => 123456}, as(@staff_user)
        assert_response 404
      end

      should "use the edit template when not XHR" do
        get :edit, {:id => @page.id}, as(@staff_user)
        assert_response 200
        assert_template 'admin/pages/edit'
      end
    end

    context "successful update via XHR" do
      setup do
        xhr :put, :update, { :id => @page.id, :content => { :content => "<p>I am new.</p>" } }, as(@staff_user)
      end

      should "find content by id" do
        assert_equal @page, assigns(:page)
      end

      should "save changes as new version" do
        assert_equal 2, @page.versions.count
        assert_equal "<p>I am new.</p>", @page.versions(:reload).last.content
        assert @page.next_version
      end

      should "respond with JSON" do
        json = ActiveSupport::JSON.decode @response.body
        expected = {'content' => "<p>I am new.</p>", 'version' => 2}
        assert_equal expected, json
      end
    end

    context "successful update via POST (ie, Admin Edit)" do
      setup do
        put :update, {:id => @page.id, :page => { :content => '<p>I am edited from the dashboard.</p>'} }, as(@staff_user)
      end

      should "find content by id" do
        assert_equal @page, assigns(:page)
      end

      should "save changes as new version" do
        assert_equal 2, @page.versions.count
        assert_equal "<p>I am edited from the dashboard.</p>", @page.versions(:reload).last.content
        assert @page.next_version
      end

      should "redirect to new version" do
        assert_redirected_to :action => 'edit', :id => @page.versions(:reload).last.id
      end
    end

    context "when updating and the version being edited is dynamic" do
      setup do
        @dynamic = create_approved_page :dynamic_content => true, :path => 'path/to/dynamic_page.html', :content => "<p>This is my page.</p>"
        xhr :put, :update, { :id => @dynamic.id, :content => { :content => "<p>I am new.</p>" } }, as(@staff_user)
      end

      should "create a new dynamic version" do
        new_version = assigns(:version)
        assert_equal @dynamic.path, new_version.path, "still same path"
        assert new_version.dynamic_content, "new version is also dynamic"
        assert_equal '<p>I am new.</p>', new_version.content, "new version has new content"
        assert !new_version.approved?, "but it isn't approved yet"
      end
    end
  end

  context "given a page with several versions" do
    setup do
      @staff_user = create_staff_user
      @first = Page.create(new_page({:path => '/path/to/stuff.html', :content => 'First version'}).attributes)
      @second = @first.new_version :content => 'Second'
      @third = @second.new_version :content => 'Third'
      @third.approve!
    end

    should "find latest version and redirect" do
      get :find_by_path_and_redirect_to_latest, {:path => '/path/to/stuff.html'}, as(@staff_user)
      assert_redirected_to( :action => :edit, :id => @third.id )
    end
  end

end
