require 'test_helper'

class LogoApprovalTest < ActiveSupport::TestCase
  should_validate_presence_of :logo_request_id, :logo_file_id
  should_belong_to :logo_request
  should_belong_to :logo_file
end
