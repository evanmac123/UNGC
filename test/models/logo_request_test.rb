require 'test_helper'
require 'sidekiq/testing'

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
      create(:logo_file)
      @logo_request.logo_files << LogoFile.first

      assert_difference '@logo_request.logo_comments.count' do
        assert_difference 'ActionMailer::Base.deliveries.size' do
          Sidekiq::Testing.inline! do
            @logo_request.logo_comments.create(:body        => 'lorem ipsum',
                                               :contact_id  => @staff_user.id,
                                               :attachment  => fixture_file_upload('files/untitled.pdf', 'application/pdf'),
                                               :state_event => :approve)
          end
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

  context "scopes" do

    setup do
      create(:organization_type)
      create(:country)
      create(:organization)
      create(:contact)
      create(:logo_publication)
    end

    should "get pending_review requests" do
      request = create(:logo_request, state: 'pending_review')
      assert request.pending_review?
      assert_contains LogoRequest.pending_review, request
    end

    should "get in_review requests" do
      contact = create(:contact)
      request = create(:logo_request, state: 'in_review', contact: contact)
      request.logo_comments.create! contact: request.contact, body: 'test', attachment: create_file_upload
      request.update_attributes(replied_to:true)

      assert request.replied_to
      assert request.in_review?
      assert_equal request.logo_comments.length, 1
      assert_contains LogoRequest.in_review, request
    end

    should "get unreplied requests" do
      contact = create(:contact)
      request = create(:logo_request, state: 'in_review', contact: contact)
      request.logo_comments.create! contact: request.contact, body: 'test', attachment: create_file_upload

      refute request.replied_to
      assert request.in_review?
      assert_contains LogoRequest.unreplied, request
    end

    should "get approved requests" do
      request = create(:logo_request, state: 'approved')

      assert request.approved?
      assert_contains LogoRequest.approved_or_accepted, request
    end

    should "get accepted requests" do
      request = create(:logo_request, state: 'accepted')

      assert request.accepted?
      assert_contains LogoRequest.approved_or_accepted, request
    end

    should "get rejected requests" do
      request = create(:logo_request, state: 'rejected')

      assert request.rejected?
      assert_contains LogoRequest.rejected, request
    end

  end

end
