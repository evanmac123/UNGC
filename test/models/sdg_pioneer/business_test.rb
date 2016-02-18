require 'test_helper'

class BusinessTest < ActiveSupport::TestCase

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

  should 'accept known country names' do
    country = create_country
    nomination = new_sdg_pioneer_business(country_name: country.name)

    assert nomination.valid?, nomination.errors.messages
  end

  should 'reject unknown country names' do
    nomination = new_sdg_pioneer_business(country_name: 'Foolandia')
    refute nomination.valid?

    validation_message = I18n.t('sdg_pioneer.validations.country_name')
    assert_includes nomination.errors.messages[:country_name], validation_message
  end

end
