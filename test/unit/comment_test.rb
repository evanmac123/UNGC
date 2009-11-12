require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  should_validate_presence_of :body
  should_belong_to :commentable
  should_belong_to :contact
end
