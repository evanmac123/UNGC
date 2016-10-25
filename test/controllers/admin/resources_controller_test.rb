require 'test_helper'

class Admin::ResourcesControllerTest < ActionController::TestCase

  def create_website_editor
    user = create_staff_user
    user.roles << Role.website_editor
    user
  end

  context "When not signed in." do
    should "not have access" do
      get :index
      assert_response 302
    end
  end

  context "When signed in as a website editor." do
    should "approve the resource" do
      sign_in create_website_editor
      resource = create(:resource)
      post :approve, id:resource
      assert_redirected_to action: :show
      resource.reload
      assert resource.approved?
    end

    should "revoke the resource" do
      sign_in create_website_editor
      resource = create(:resource)
      resource.approve!
      post :revoke, id:resource
      assert_redirected_to action: :show
      resource.reload
      assert resource.revoked?
    end

  end

  context "When signed in, but not from the UNGC" do
    should "not have access" do
      sign_in create_organization_and_user
      get :index
      assert_response 302
    end
  end

  context "When signed in as a member of the UNGC" do

    setup do
      sign_in create_staff_user
    end

    should "get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:resources)
    end

    should "get show" do
      resource = create(:resource)
      get :show, id:resource
      assert_response :success
      assert_not_nil assigns(:resource)
    end

    should "get new" do
      get :new
      assert_response :success
      assert_not_nil assigns(:resource)
    end

    should "get edit" do
      resource = create(:resource)
      get :edit, id:resource
      assert_response :success
      assert_not_nil assigns(:resource)
    end

    should "delete" do
      resource = create(:resource)
      delete :destroy, id:resource
      assert_redirected_to action: :index
      assert_equal 0, Resource.count
    end

    should "not be able to approve a resource" do
      resource = create(:resource)
      post :approve, id:resource

      resource.reload
      refute resource.approved?
    end

    should "not be able to revoke a resource" do
      resource = create(:resource)
      resource.approve!
      post :revoke, id:resource

      resource.reload
      refute resource.revoked?
    end

    should "save the year as a date." do

    end

    context "with valid attributes" do

      should "create and redirect to the index" do
        post :create, resource:params
        assert_redirected_to action: :index
        assert_equal 1, Resource.count
      end

      should "update and redirect to show" do
        resource = create(:resource)

        put :update, id: resource, resource: params

        assert_redirected_to action: :show
      end
    end

    context "with invalid attributes" do

      should "render new action" do
        post :create, resource:{}
        assert_template :new
        assert_equal 0, Resource.count
      end

      should "render edit action" do
        resource = create(:resource)
        put :update, id:resource, resource:{title: nil}
        assert_template :edit
      end
    end

    context "adding a resource with links" do
      should "create and redirect to the index" do
        post :create, resource:params.merge(links: [
          {id: nil, title: "test", url: 'http://url1.com', language_id: 1, link_type: 'pdf'},
          {id: nil, title: "test2", url: 'http://url2.com', language_id: 12, link_type: 'pdf'}
        ])
        assert_redirected_to action: :index
        assert_equal 2, ResourceLink.count
      end
    end

    context "edit a resource with links" do
      should "edit the links for a resource" do
        resource = create(:resource)
        id1 = resource.links.create({title: "test", url: 'http://url1.com', language_id: 1, link_type: 'pdf'})
        id2 = resource.links.create({title: "test2", url: 'http://url2.com', language_id: 1, link_type: 'pdf'})

        put :update, id: resource, resource: params.merge(links: [
          {title: "test3", url: 'http://url3.com', language_id: 3, link_type: 'pdf'},
          {id: id2, title: "test2 2", url: 'http://url2.com', language_id: 1, link_type: 'pdf'},
          {title: "test4", url: 'http://url4.com', language_id: 1, link_type: 'pdf'}
        ])
        assert_redirected_to action: :show
        assert_equal 3, ResourceLink.count
      end
    end

    context "upload an image for a resource" do
      should "create and redirect to the index" do
        post :create, resource: params.merge({:image => fixture_file_upload('files/untitled.jpg', 'image/jpeg') })
        assert_redirected_to action: :index
        assert Resource.last.image.file?
      end
    end

    context "set the content_type for a resource" do
      should "create and redirect to the index" do
        post :create, resource: params.merge({content_type: 'webinar' })
        assert_redirected_to action: :index
        assert_equal Resource.last.content_type, 'webinar'
      end
    end
  end

  private

  def params
    attributes_for(:resource)
    .with_indifferent_access.slice(
      :title, :description
    )
  end
end
