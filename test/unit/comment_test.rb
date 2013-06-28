require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  should belong_to :commentable
  should belong_to :contact

  context 'given an existing commentable' do
    setup do
      create_organization_and_user
      create_staff_user
    end

    should "update replied_to to true and reviewer_id after comment is added by ungc staff" do
      assert !@organization.replied_to
      assert_difference 'Comment.count' do
        @organization.comments.create(:body => 'from organization',
                                      :contact_id => @staff_user.id)
      end
      @organization.reload
      assert @organization.replied_to
      assert_equal @staff_user, @organization.reviewer
    end

    should "update replied_to to false and reviewer_id after comment is added by organization" do
      assert_difference 'Comment.count' do
        @organization.comments.create(:body => 'from organization',
                                      :contact_id => @organization_user.id)
      end
      @organization.reload
      assert !@organization.replied_to
      assert_nil @organization.reviewer
    end

    should "get the full name (contact.name) of the user who posted the last comment" do
      @organization.comments.create(:body => 'new comment',
                                    :contact_id => @organization_user.id)
      assert_equal @organization.last_comment_author, @organization_user.name
    end
  end

end
