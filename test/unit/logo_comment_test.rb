require 'test_helper'

class LogoCommentTest < ActiveSupport::TestCase
  should validate_presence_of :contact_id
  should validate_presence_of :body
  should belong_to :logo_request
  should belong_to :contact

  context "give a new logo request" do
    setup do
      create_new_logo_request
    end

    should "only approve with comment if approved logos have been selected" do
      assert_no_difference '@logo_request.logo_comments.count' do
        @logo_request.logo_comments.create(:body        => 'lorem ipsum',
                                           :contact_id  => @staff_user.id,
                                           :attachment  => fixture_file_upload('files/untitled.pdf', 'application/pdf'),
                                           :state_event => LogoRequest::EVENT_APPROVE)
      end
    end

    should "go to 'in review' state with a comment" do
      assert_difference '@logo_request.logo_comments.count' do
        assert_difference 'ActionMailer::Base.deliveries.size' do
          @logo_request.logo_comments.create(:body        => 'lorem ipsum',
                                             :contact_id  => @staff_user.id,
                                             :attachment  => fixture_file_upload('files/untitled.pdf', 'application/pdf'),
                                             :state_event => LogoRequest::EVENT_REVISE)
          assert @logo_request.reload.in_review?
        end
      end
    end
  end

  context "given a 'in review' logo request" do
    setup do
      create_new_logo_request
      @logo_request.logo_comments.create(:body        => 'lorem ipsum',
                                         :contact_id  => @staff_user.id,
                                         :attachment  => fixture_file_upload('files/untitled.pdf', 'application/pdf'),
                                         :state_event => LogoRequest::EVENT_REVISE)
      @logo_request.logo_files << create_logo_file
    end

    should "go to approved state after approval comment" do
      assert_difference '@logo_request.logo_comments.count' do
        assert_difference 'ActionMailer::Base.deliveries.size' do
          @logo_request.logo_comments.create(:body        => 'lorem ipsum',
                                             :contact_id  => @staff_user.id,
                                             :state_event => LogoRequest::EVENT_APPROVE)
          assert @logo_request.reload.approved?
        end
      end
    end

    should "set a default body to an approval comment" do
      assert_difference '@logo_request.logo_comments.count' do
        assert_difference 'ActionMailer::Base.deliveries.size' do
          logo_comment = @logo_request.logo_comments.create(:contact_id  => @staff_user.id,
                                                            :state_event => LogoRequest::EVENT_APPROVE)
          assert_equal 'Your logo request has been approved.', logo_comment.reload.body
        end
      end
    end

    should "go to rejected state after negative comment" do
      assert_difference '@logo_request.logo_comments.count' do
        assert_difference 'ActionMailer::Base.deliveries.size' do
          @logo_request.logo_comments.create(:body        => 'lorem ipsum',
                                             :contact_id  => @staff_user.id,
                                             :state_event => LogoRequest::EVENT_REJECT)
          assert @logo_request.reload.rejected?
        end
      end
    end

    should "not go to approved/rejected state after comment from organization" do
      assert_no_difference '@logo_request.logo_comments.count' do
        assert_no_difference 'ActionMailer::Base.deliveries.size' do
          @logo_request.logo_comments.create(:body        => 'lorem ipsum',
                                             :contact_id  => @organization_user.id,
                                             :state_event => LogoRequest::EVENT_APPROVE)
          assert !@logo_request.reload.approved?
        end
      end
    end
  end

  context "given an approved/rejected logo request" do
    setup do
      create_approved_logo_request
    end

    should "not accept new comments" do
      assert_no_difference '@logo_request.logo_comments.count' do
        assert_no_difference 'ActionMailer::Base.deliveries.size' do
          @logo_request.logo_comments.create(:body        => 'lorem ipsum',
                                             :contact_id  => @organization_user.id,
                                             :attachment  => fixture_file_upload('files/untitled.pdf', 'application/pdf'),
                                             :state_event => LogoRequest::EVENT_REPLY)
        end
      end
    end
  end
end
