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
      create_organization_and_ceo
      create_local_network_with_report_recipient
      @organization.country_id = @local_network.country_ids.first
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

    should "send email to Local Network when organization status is changed to Network Review" do
      assert_difference 'Comment.count' do
        assert_emails(1) do
          post :create, :organization_id    => @organization.id,
                        :commit             => Organization::EVENT_NETWORK_REVIEW,
                        :comment            => { :body => 'Your application is under review by the Local Network in your country.'}

          assert_redirected_to admin_organization_path(@organization.id)
          assert_equal 'The application is now under review by the Local Network.', flash[:notice]
          assert @organization.reload.state, 'network_review'
        end
      end
    end
        
    should "approve the organization on approval comment" do
      assert_difference 'Comment.count' do
        # we expect two emails - approval and foundation invoice
        assert_emails(2) do
          post :create, :organization_id => @organization.id,
                        :commit          => Organization::EVENT_APPROVE,
                        :comment         => { :body => '' }

          # empty comment should have default message
          assert_equal 'Your application has been accepted.', @organization.comments.first.body
          assert_redirected_to admin_organization_path(@organization.id)
          assert_equal 'The application was approved.', flash[:notice]
          assert @organization.reload.approved?
        end
      end
    end
    
    should "reject the organization on rejection comment" do
      assert_difference 'Comment.count' do
        assert_emails(0) do        
          post :create, :organization_id => @organization.id,
                        :commit          => Organization::EVENT_REJECT,
                        :comment         => { :body => 'Rejected' }

          assert_redirected_to admin_organization_path(@organization.id)
          assert_equal 'The application was rejected.', flash[:notice]
          assert @organization.reload.rejected?
        end
      end
    end

    should "reject the micro enterprise organization on reject micro comment" do
      assert_difference 'Comment.count' do
        assert_emails(1) do
          post :create, :organization_id => @organization.id,
                        :commit          => Organization::EVENT_REJECT_MICRO,
                        :comment         => { :body => 'Rejected' }

          assert_redirected_to admin_organization_path(@organization.id)
          assert_equal 'The Micro Enterprise application was rejected.', flash[:notice]
          assert @organization.reload.rejected?
        end
      end
    end
    
  end # content
  
end
