require 'test_helper'

class SdgPioneer::SubmissionTest < ActionDispatch::IntegrationTest

  test 'Anonymous user submits a nomination' do
    create_country(name: 'Canada')
    create_business(name: "McExampleson's Emporium")
    sdg1, _, sdg3 = 3.times.map { create_sustainable_development_goal }

    path = sdg_pioneer_index_path
    container = create_container(path: path)
    payload = new_payload(container_id: container.id)
    container.draft_payload = payload
    ContainerPublisher.new(container, create_staff_user).publish

    visit new_sdg_pioneer_submission_path

    choose  'business_is_nominated_true'
    fill_in 'business_nominating_organization', with: 'Nominators R Us', visible: false
    fill_in 'business_nominating_individual', with: 'Nominates McGee', visible: false
    fill_in 'business_contact_person_name', with: "Cathy McExampleson"
    fill_in 'business_contact_person_title', with: 'Most Contacted Person'
    fill_in 'business_contact_person_email', with: 'contact-person@example.com'
    fill_in 'business_contact_person_phone', with: '1 (123) 123-1234'
    fill_in 'business_organization_name', with: "McExampleson's Emporium"
    fill_in 'business_local_business_name', with: "Haha company"
    choose  'business_is_participant_false'
    fill_in 'business_country_name', with: 'Canada'
    choose  'business_local_network_status_no'
    fill_in 'business_website_url', with: 'https://example.com/document.html'

    fill_in 'business_positive_outcomes', with: 'Outcomes were positive...'
    attach_file('business_uploaded_positive_outcome_attachments__attachment', File.absolute_path('./test/fixtures/files/untitled.pdf'))

    check sdg1.name, visible: true
    check sdg3.name, visible: true

    fill_in 'business_other_relevant_info', with: 'Other_relevant_info'

    check 'business_accepts_tou'

    # submit the nomination
    assert_difference -> { SdgPioneer::Submission.count }, +1 do
      click_on 'Submit'
    end

    # we should be on the landing page with a notice about our submission
    assert_equal sdg_pioneer_index_path, current_path
    assert_equal I18n.t('sdg_pioneer.nominated'), find('.success-message').text

    # we should have created an attachment
    business = SdgPioneer::Submission.last
    assert_not_nil business


    assert business.is_nominated?
    assert_equal 'Nominators R Us', business.nominating_organization
    assert_equal 'Nominates McGee', business.nominating_individual
    assert_equal "Cathy McExampleson", business.contact_person_name
    assert_equal 'Most Contacted Person', business.contact_person_title
    assert_equal 'contact-person@example.com', business.contact_person_email
    assert_equal '1 (123) 123-1234', business.contact_person_phone
    assert_equal "McExampleson's Emporium", business.organization_name
    assert business.organization_name_matched?
    assert_equal 'Haha company', business.local_business_name
    assert_equal false, business.is_participant?
    assert_equal 'Canada', business.country_name
    assert_equal 'no', business.local_network_status
    assert_equal 'https://example.com/document.html', business.website_url

    assert_equal 'Outcomes were positive...', business.positive_outcomes

    outcome_attachment = business.positive_outcome_attachments.first
    assert_not_nil outcome_attachment
    assert_equal 'untitled.pdf', outcome_attachment.filename

    assert_equal [sdg1.id, sdg3.id], business.matching_sdgs
    assert_equal 'Other_relevant_info', business.other_relevant_info
    assert business.accepts_tou?
  end

end
