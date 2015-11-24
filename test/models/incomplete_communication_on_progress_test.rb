require 'test_helper'

class IncompleteCommunicationOnProgressTest < ActiveSupport::TestCase

  setup do
    @organization = create_organization
  end

  should 'not include incomplete cops in the COP list' do
    incomplete = IncompleteCommunicationOnProgress.create!(title: 'hi', organization: @organization)
    assert_not_includes CommunicationOnProgress.all, incomplete
  end

  should 'have the right type' do
    incomplete = IncompleteCommunicationOnProgress.create!(title: 'hi', organization: @organization)
    assert_not_nil incomplete.type
  end

  should 'be able to complete a COP in progress' do
    incomplete = IncompleteCommunicationOnProgress.create!(title: 'hi', organization: @organization)
    incomplete.references_human_rights = true
    incomplete.save

    # need to validate
    completed = incomplete.complete!
    assert_equal completed.references_human_rights, true
  end

end
