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

    choose  'submission_pioneer_type_local_business_leader'
    fill_in 'submission_name', with: "Cathy McExampleson"
    fill_in 'submission_title', with: 'Most Contacted Person'
    fill_in 'submission_email', with: 'contact-person@example.com'
    fill_in 'submission_phone', with: '1 (123) 123-1234'
    fill_in 'submission_organization_name', with: "McExampleson's Emporium"
    choose  'submission_is_participant_false'
    fill_in 'submission_country_name', with: 'Canada'
    fill_in 'submission_website_url', with: 'https://example.com/document.html'
    fill_in 'submission_global_goals_activity', with: 'My activity'
    fill_in 'submission_reason_for_being', with: 'My reasons...'

    attach_file('submission_uploaded_supporting_documents__attachment', File.absolute_path('./test/fixtures/files/untitled.pdf'))

    check sdg1.name, visible: true
    check sdg3.name, visible: true

    check 'submission_accepts_tou'

    # submit the nomination
    assert_difference -> { SdgPioneer::Submission.count }, +1 do
      click_on 'Nominate'
    end

    # we should be on the landing page with a notice about our submission
    assert_equal sdg_pioneer_index_path, current_path
    assert_equal I18n.t('sdg_pioneer.nominated'), find('.success-message').text

    # we should have created an attachment
    submission = SdgPioneer::Submission.last
    assert_not_nil submission

    assert_equal "Cathy McExampleson", submission.name
    assert_equal 'Most Contacted Person', submission.title
    assert_equal 'contact-person@example.com', submission.email
    assert_equal '1 (123) 123-1234', submission.phone
    assert_equal "McExampleson's Emporium", submission.organization_name
    assert submission.organization_name_matched?
    assert_equal false, submission.is_participant?
    assert_equal 'Canada', submission.country_name
    assert_equal 'https://example.com/document.html', submission.website_url

    assert_equal 'My activity', submission.global_goals_activity

    attachment = submission.supporting_documents.first
    assert_not_nil attachment
    assert_equal 'untitled.pdf', attachment.filename

    assert_equal [sdg1.id, sdg3.id], submission.matching_sdgs
    assert_equal 'My reasons...', submission.reason_for_being
    assert submission.accepts_tou?
  end

end
