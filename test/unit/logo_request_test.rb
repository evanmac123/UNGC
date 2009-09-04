require 'test_helper'

class LogoRequestTest < ActiveSupport::TestCase
  should_validate_presence_of :organization_id, :publication_id
  should_belong_to :organization
  should_belong_to :contact
  should_belong_to :publication
  should_have_many :logo_comments
end
