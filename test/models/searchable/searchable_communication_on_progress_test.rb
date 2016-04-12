require 'test_helper'

class Searchable::SearchableCommunicationOnProgressTest < ActiveSupport::TestCase
  include SearchableModelTests

  def subject
    @org_type ||= create(:organization_type)
    @org ||= create(:organization)
    @cop ||= create(:communication_on_progress)
  end

end
