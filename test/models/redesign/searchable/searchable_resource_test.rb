require 'test_helper'

class Redesign::Searchable::SearchableResourceTest < ActiveSupport::TestCase
  include SearchableModelTests
  include SearchableTagTests

  private

  def resource
    @resource ||= create_resource.tap { |o| o.approve! }
  end

  alias_method :subject, :resource

end
