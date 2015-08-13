require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase

  context 'cop_link' do

    should 'link to cops with a differentiation level' do
      assert_equal "/participation/report/cop/create-and-submit/active/#{cop.id}", cop_link(cop, :active)
    end

    should 'link to cops with a default differentiation level' do
      assert_equal "/participation/report/cop/create-and-submit/learner/#{cop.id}", cop_link(cop)
    end

  end

  private

  def cop
    @org_type ||= create_organization_type
    @org ||= create_organization
    @cop ||= create_communication_on_progress
  end

end
