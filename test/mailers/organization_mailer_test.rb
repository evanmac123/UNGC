require 'test_helper'
class OrganizationMailerTest < ActionMailer::TestCase

  test 'new_review_for_research' do
    country = create(:country, :with_local_network)
    organization = create(:organization, :participant_level, :has_participant_manager, country: country)


    mail = OrganizationMailer.level_of_participation_chosen(organization)

    assert_includes mail.subject, "Engagement Tier 'Participant Level' Selected By:"
    assert_includes mail.subject, organization.name
    assert_includes mail.to, organization.local_network.contacts.network_contacts.first.email,
                    'Email not send to Network Focal Point contact'
    assert_nil mail.reply_to
    assert_equal ['localnetworks@unglobalcompact.org'], mail.from
  end
end
