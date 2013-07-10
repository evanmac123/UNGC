require 'test_helper'

class Admin::CaseStoriesControllerTest < ActionController::TestCase
  context "given a pending organization" do
    setup do
      create_organization_and_user
      sign_in @organization_user
    end

    should "not be able to get new case story form" do
      get :new, :organization_id => @organization.id
      assert_redirected_to admin_organization_path(@organization.id)
    end
  end

  context "given an approved organization" do
    setup do
      create_organization_and_user
      @organization.approve!
      sign_in @organization_user
    end

    should "be able to get new case story form" do
      get :new, :organization_id => @organization.id
      assert_response :success
    end

    should "be able to save a new case story" do
      assert_difference "CaseStory.count" do
        post :create, :organization_id => @organization.id,
                      :case_story => { :title => 'Lorem ipsum' }
        assert_response :redirect
      end
    end
  end

  context "given an existing case story" do
    setup do
      create_organization_and_user
      @organization.approve!
      sign_in @organization_user
      @case_story = create_case_story(:organization_id => @organization.id)
    end

    should "be able to see the case story" do
      get :show, :organization_id => @organization.id,
                 :id              => @case_story.id
      assert_response :success
    end

    should "be able to edit the case story" do
      get :edit, :organization_id => @organization.id,
                 :id              => @case_story.id
      assert_response :success
    end
  end
end
