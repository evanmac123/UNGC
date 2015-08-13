require 'test_helper'

class Searchable::SearchableCommunicationOnProgressTest < ActiveSupport::TestCase
  include SearchableModelTests

  def subject
    @org_type ||= create_organization_type
    @org ||= create_organization
    @cop ||= create_communication_on_progress
  end

end
