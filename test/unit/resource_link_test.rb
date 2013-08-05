require 'test_helper'

class ResourceLinkTest < ActiveSupport::TestCase
  should belong_to :resource
  should belong_to :language
end
