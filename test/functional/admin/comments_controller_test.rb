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
      create_local_network_with_report_recipient
      @organization.country_id = @country.id
      login_as @staff_user
    end

    should "also send email to the Local Network when posting a comment" do      
      assert_difference 'Comment.count' do
        # FIXME: we expect *two* emails - one to the applicant, and one to the network (if the checkbox is checked)
        assert_emails(1) do
          post :create, :organization_id    => @organization.id,
                        :commit             => Organization::EVENT_REVISE,
                        :comment            => { :body => 'Please revise your application.', :copy_local_network => '1' }

          assert_redirected_to admin_organization_path(@organization.id)
          assert_equal 'Comment was successfully created. The Local Network has been notified by email.', flash[:notice]
          assert @organization.reload.state, 'in_review'
        end
      end
    end

    should "only email comment to application organization" do
      assert_difference 'Comment.count' do
        assert_emails(1) do
          post :create, :organization_id    => @organization.id,
                        :commit             => Organization::EVENT_REVISE,
                        :comment            => { :body => 'Please revise your application.', :copy_local_network => '0' }

          assert_redirected_to admin_organization_path(@organization.id)
          assert_equal 'Comment was successfully created.', flash[:notice]
          assert @organization.reload.state, 'in_review'
        end
      end
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
