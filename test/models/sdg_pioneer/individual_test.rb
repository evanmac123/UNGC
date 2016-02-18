require 'test_helper'

class IndividualTest < ActiveSupport::TestCase

  should 'require a value for is_participant' do
    nomination = new_sdg_pioneer_business(is_participant: nil)
    refute nomination.valid?
    assert nomination.errors.messages[:is_participant].present?
  end

  should 'accept false as a value for is_participant' do
    nomination = new_sdg_pioneer_business(is_participant: false)
    assert nomination.valid?, nomination.errors.messages
  end

  should 'accept active participant names for company' do
    participant = create_organization(active: true, participant: true)
    nomination = new_sdg_pioneer_business(organization_name: participant.name)
    assert nomination.valid?, nomination.errors.messages
  end

end
