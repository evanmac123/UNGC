require 'test_helper'

class LogoRequestTest < ActiveSupport::TestCase
  should validate_presence_of :organization_id
  should validate_presence_of :publication_id
  should validate_presence_of :purpose
  should belong_to :organization
  should belong_to :contact
  should belong_to :publication
  should have_many :logo_comments

  context "given a new logo request" do
    setup do
      create_new_logo_request
    end

    should "have default state of pending review" do
      assert_equal :pending_review, @logo_request.state_name
    end

    should "change state to approved if a positive comment is added" do
      # no approved logo, can't approve now
      assert_no_difference '@logo_request.logo_comments.count' do
        @logo_request.logo_comments.create(:body        => 'lorem ipsum',
                                           :contact_id  => @staff_user.id,
                                           :attachment  => fixture_file_upload('files/untitled.pdf', 'application/pdf'),
                                           :state_event => :approve)
      end
      assert !@logo_request.reload.approved?
      # add approved logo, then approve
      create_logo_file
      @logo_request.logo_files << LogoFile.first
      assert_difference '@logo_request.logo_comments.count' do
        assert_difference 'ActionMailer::Base.deliveries.size' do
          @logo_request.logo_comments.create(:body        => 'lorem ipsum',
                                             :contact_id  => @staff_user.id,
                                             :attachment  => fixture_file_upload('files/untitled.pdf', 'application/pdf'),
                                             :state_event => :approve)
        end
      end
      assert @logo_request.reload.approved?
      assert_equal Date.today, @logo_request.approved_on
    end

    should "make sure only ungc staff can approve or reject" do
      assert_no_difference '@logo_request.logo_comments.count' do
        @logo_request.logo_comments.create(:body        => 'lorem ipsum',
                                           :contact_id  => @organization_user.id,
                                           :state_event => :approve)
      end
      assert !@logo_request.reload.approved?
    end
  end

end
