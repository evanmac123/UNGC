require 'test_helper'

class SubmissionTest < ActiveSupport::TestCase

  should 'require a value for accepts_tou' do
    nomination = build(:sdg_pioneer_submission, accepts_tou: nil)
    refute nomination.valid?
    assert nomination.errors.messages[:accepts_tou].present?
  end

  should 'accept false as a value for accepts_tou' do
    nomination = build(:sdg_pioneer_submission, accepts_tou: false)
    assert nomination.valid?, nomination.errors.messages
  end

  should 'accept active participant names for company' do
    participant = create(:business, level_of_participation: "signatory_level")
    nomination = build(:sdg_pioneer_submission, organization_name: participant.name)
    assert nomination.valid?, nomination.errors.messages
  end

  should 'accept known country names' do
    country = create(:country)
    nomination = build(:sdg_pioneer_submission, country_name: country.name)

    assert nomination.valid?, nomination.errors.messages
  end

  should 'reject unknown country names' do
    nomination = build(:sdg_pioneer_submission, country_name: 'Foolandia')
    refute nomination.valid?

    validation_message = I18n.t('sdg_pioneer.validations.country_name')
    assert_includes nomination.errors.messages[:country_name], validation_message
  end

  should "require has local network engagement" do
    nomination = build(:sdg_pioneer_submission, has_local_network: nil)
    refute nomination.valid?
    assert_contains nomination.errors.full_messages, "Has local network is not included in the list"
  end

  should "require accepts interview" do
    nomination = build(:sdg_pioneer_submission, accepts_interview: nil)
    refute nomination.valid?
    assert_contains nomination.errors.full_messages, "Accepts interview is not included in the list"
  end

  should "require an answer for local network question" do
    nomination = build(:sdg_pioneer_submission, local_network_question: "")
    refute nomination.valid?
    assert_contains nomination.errors.full_messages, "Local network question can't be blank"
  end

  private

  def create_participant
    create(:business, level_of_participation: "signatory_level")
  end
end
