require 'test_helper'

class Admin::CommentsControllerTest < ActionController::TestCase
  context "given an existing case story" do
    setup do
      create_new_case_story
      login_as @organization_user
    end
    
    should "be able to get new comment form" do
      get :new, :organization_id => @organization.id,
                :case_story_id   => @case_story.id
      assert_response :success
    end
    
    should "be able to save a new comment" do
      assert_difference "Comment.count" do
        post :create, :organization_id => @organization.id,
                      :case_story_id   => @case_story.id,
                      :commit          => 'revise',
                      :comment         => { :body => 'Lorem ipsum' }
        assert_response :redirect
      end
    end
  end
  
  context "given an existing organization" do
    setup do
      create_ungc_organization_and_user
      create_organization_and_user
      login_as @staff_user
    end
    
    should "approve the organization on approval comment" do
      assert_difference 'Comment.count' do
        # we expect two emails - approval and foundation invoice
        assert_emails(2) do
          post :create, :organization_id => @organization.id,
                        :commit          => Organization::EVENT_APPROVE,
                        :comment         => { :body => 'Approved' }

          assert_redirected_to admin_organization_path(@organization.id)
          assert @organization.reload.approved?
        end
      end
    end
    
    should "reject the organization on rejection comment" do
      assert_difference 'Comment.count' do
        post :create, :organization_id => @organization.id,
                      :commit          => Organization::EVENT_REJECT,
                      :comment         => { :body => 'Rejected' }

        assert_redirected_to admin_organization_path(@organization.id)
        assert @organization.reload.rejected?
      end
    end
  end
end
