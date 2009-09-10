require 'test_helper'

class LogoRequestTest < ActiveSupport::TestCase
  should_validate_presence_of :organization_id, :publication_id
  should_belong_to :organization
  should_belong_to :contact
  should_belong_to :publication
  should_have_many :logo_comments

  context "given a new logo request" do
    setup do
      create_new_logo_request
    end

    should "have default state of pending review" do
      assert_equal :pending_review, @logo_request.state_name
    end

    should "change state to approved if a positive comment is added" do
      @logo_request.logo_comments.create(:body        => 'lorem ipsum',
                                         :contact_id  => Contact.first.id,
                                         :state_event => :approve)
      assert @logo_request.reload.approved?
    end

    should "make sure only ungc staff can approve or reject" do
      # TODO implement after authorization
    end

    should "allow multiple comments by organization user without changing state" do
      # TODO implement after authorization
    end
  end
end
