require 'test_helper'

class Admin::ContentControllerTest < ActionController::TestCase
  context "given some content" do
    setup do
      @content = create_approved_content :path => 'path/to/content.html', :content => "<p>This is my content.</p>"
    end

    context "successful edit action" do
      setup do
        # TODO: should be a staff user
        xhr :get, :edit, :id => @content.id
      end

      should "find content by id" do
        assert_equal @content, assigns(:content)
        assert_response :success
      end
      
      should "respond with JSON" do
        json = ActiveSupport::JSON.decode @response.body
        assert_same_elements %w{url content}, json.keys
        assert_same_elements [ 
          update_content_url(:id => @content.id, :format => 'js'),
          @content.content
        ], json.values
      end
    end
    
    context "edit a specific version" do
      setup do
        @version = @content.versions.create :content => "<p>I am new.</p>"
        xhr :get, :edit, :id => @content.id, :version => @version.number
      end

      should "respond with that version's contents" do
        json = ActiveSupport::JSON.decode @response.body
        content = json['content']
        assert_equal "<p>I am new.</p>", content
      end
    end    
    
    context "bad edit action" do
      should "issue a 404 when content not found" do
        xhr :get, :edit, :id => 123456
        assert_response 404
      end
      
      should "issue a 403 when not an XHR" do
        get :edit, :id => @content.id
        assert_response 403
      end
    end
    
    context "successful update via XHR" do
      setup do
        xhr :put, :update, { :id => @content.id, :content => { :content => "<p>I am new.</p>" } }
      end

      should "find content by id" do
        assert_equal @content, assigns(:content)
      end

      should "save changes as new version" do
        assert_equal 2, @content.versions.count
        assert_equal "<p>I am new.</p>", @content.versions(:reload).last.content
        assert @content.next_version
      end
      
      should "respond with JSON" do
        json = ActiveSupport::JSON.decode @response.body
        expected = {'content' => "<p>I am new.</p>", 'version' => 2}
        assert_equal expected, json
      end
    end
    
  end
  
end
