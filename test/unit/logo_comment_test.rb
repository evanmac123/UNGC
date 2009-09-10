require 'test_helper'

class LogoCommentTest < ActiveSupport::TestCase
  should_validate_presence_of :logo_request_id, :contact_id, :body
  should_belong_to :logo_request
  should_belong_to :contact
  
  context "given an approved/rejected logo request" do
    setup do
      create_new_logo_request
      # we need a comment before approving
      @logo_request.logo_comments.create(:body        => 'lorem ipsum',
                                         :contact_id  => Contact.first.id,
                                         :state_event => LogoRequest::EVENT_REVISE)
      @logo_request.approve
    end
    
    should "not accept new comments" do
      assert_no_difference '@logo_request.logo_comments.count' do
        @logo_request.logo_comments.create(:body        => 'lorem ipsum',
                                           :contact_id  => Contact.first.id,
                                           :state_event => LogoRequest::EVENT_REPLY)
      end
    end
  end
end
