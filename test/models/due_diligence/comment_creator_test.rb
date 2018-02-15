require 'test_helper'
require 'sidekiq/testing'

class CommentCreatorTest < ActiveSupport::TestCase
  context "a comment" do
    setup do
      @review = FactoryBot.create(:due_diligence_review, :engagement_review, :rejected)
      @commentor = FactoryBot.create(:contact)
      @creator = DueDiligence::CommentCreator.new(@review, @commentor)
      @comment_params = {
        body: "Hello World",
        notify_participant_manager: "0"
      }
      Sidekiq::Testing.inline!
    end

    should "successfully create a comment" do
      assert_difference 'Comment.count', 1 do
        @creator.create_comment(@comment_params)
      end
    end

    should 'create event' do
      event_params = { data:
               {
                 body: "Hello World",
                 contact_id: @commentor.id
               }
             }

      event = DueDiligence::Events::CommentCreated.new(event_params)
      @creator.create_comment(@comment_params)
      assert_not_nil event = event_store.read_all_streams_forward.last
      assert event.is_a?(DueDiligence::Events::CommentCreated)
      assert_equal event.data, event_params[:data]
    end

    should 'send notifications' do
      ActionMailer::Base.deliveries.clear
      @creator.create_comment(@comment_params)
      assert_equal 1, ActionMailer::Base.deliveries.count, "Expected 1 notification email to be created"
      assert_not_nil email = ActionMailer::Base.deliveries.first
      assert_equal ["integrityteam@unglobalcompact.org"], email.to
    end

    should 'notify participant manager' do
      ActionMailer::Base.deliveries.clear
      @creator.create_comment @comment_params.merge({notify_participant_manager: "1"})
      assert_equal 2, ActionMailer::Base.deliveries.count, "Expected 2 notification emails to be created"
      assert_equal ["integrityteam@unglobalcompact.org"], ActionMailer::Base.deliveries.first.to
      assert_equal [@review.organization.participant_manager_email], ActionMailer::Base.deliveries.last.to
    end

    should 'not create event if comment is not created' do
      refute @creator.create_comment({})
      event = event_store.read_all_streams_forward.last
      assert_not event.is_a? DueDiligence::Events::CommentCreated
    end

    should 'not send notifications if comment is not created' do
      assert_no_difference 'ActionMailer::Base.deliveries.count' do
        refute @creator.create_comment({})
      end
    end

    should 'not accept invalid comments' do
      refute @creator.create_comment(body: "")
    end

  end
end
