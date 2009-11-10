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
    
    should "be able to save a new case story" do
      assert_difference "Comment.count" do
        post :create, :organization_id => @organization.id,
                      :case_story_id   => @case_story.id,
                      :commit          => 'revise',
                      :comment         => { :body => 'Lorem ipsum' }
        assert_response :redirect
      end
    end
  end
end
