require 'test_helper'

class LogoCommentTest < ActiveSupport::TestCase
  should_validate_presence_of :logo_request_id, :contact_id, :body
  should_belong_to :logo_request
  should_belong_to :contact
end
