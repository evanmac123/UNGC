require 'test_helper'

class Searchable::SearchableOrganizationTest < ActiveSupport::TestCase
  include SearchableModelTests

  private

  def organization
    @organization_type ||= create_organization_type
    @organization ||= create_organization.tap { |o| o.approve! }
  end

  alias_method :subject, :organization

end