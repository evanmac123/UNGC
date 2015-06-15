require 'test_helper'

class Redesign::CopsControllerTest < ActionController::TestCase

  should "link to a COP" do
    expected = "/participation/report/cop/create-and-submit/learner/#{cop.id}"
    cop_path = show_redesign_cops_path(differentiation: cop.differentiation_level_with_default, id: cop.id)
    assert_equal expected, cop_path
  end

  should "link to a COP without a type" do
    # there are many existing COPs that lack a value for cop_type
    cop = cop(cop_type: nil)
    expected = "/participation/report/cop/create-and-submit/learner/#{cop.id}"
    cop_path = show_redesign_cops_path(differentiation: cop.differentiation_level_with_default, id: cop.id)
    assert_equal expected, cop_path
  end

  private

  def cop(attrs = {})
    @org_type ||= create_organization_type
    @org ||= create_organization
    @cop ||= create_communication_on_progress(attrs.reverse_merge(cop_type: 'basic'))
  end

end