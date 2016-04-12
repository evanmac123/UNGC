require 'test_helper'

class Searchable::SearchableResourceTest < ActiveSupport::TestCase
  include SearchableModelTests
  include SearchableTagTests

  private

  def resource
    @resource ||= create(:resource).tap { |o| o.approve! }
  end

  alias_method :subject, :resource

end
