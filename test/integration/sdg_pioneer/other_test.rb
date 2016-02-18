require 'test_helper'

class SdgPioneer::OtherTest < ActionDispatch::IntegrationTest

  test 'Other Nominate' do
    # create the landing page
    path = sdg_pioneer_index_path
    container = create_container(path: path)
    payload = new_payload(container_id: container.id)
    container.draft_payload = payload
    ContainerPublisher.new(container, create_staff_user).publish

    visit new_sdg_pioneer_other_path

    select 'UN Agency', from: 'other_organization_type'
    fill_in 'other_submitter_name', with: 'Submitter McGee'
    fill_in 'other_submitter_place_of_work', with: 'McDonalds'
    fill_in 'other_submitter_job_title', with: 'Fry Cook'
    fill_in 'other_submitter_email', with: 'submitterson@mcgee.org'
    fill_in 'other_submitter_phone', with: '123-123-1234'
    choose 'other_sdg_pioneer_role_change_makers'
    fill_in 'other_nominee_name', with: 'Auntie McGee'
    fill_in 'other_nominee_work_place', with: 'Trump Towers'
    fill_in 'other_nominee_title', with: 'Ronald McDonald'
    fill_in 'other_nominee_email', with: 'auntie@mcgee.org'
    fill_in 'other_nominee_phone', with: '432-432-4321'
    fill_in 'other_why_nominate', with: 'Hire Hamburgalur'

    assert_difference -> { SdgPioneer::Other.count }, +1 do
      click_on 'Nominate'
    end

    # we should be on the landing page with a notice about our submission
    assert_equal sdg_pioneer_index_path, current_path
    assert_equal I18n.t('sdg_pioneer.nominated'), find('.success-message').text

    other = SdgPioneer::Other.last
    assert_equal 'un', other.organization_type
    assert_equal 'Submitter McGee', other.submitter_name
    assert_equal 'McDonalds', other.submitter_place_of_work
    assert_equal 'Fry Cook', other.submitter_job_title
    assert_equal 'submitterson@mcgee.org', other.submitter_email
    assert_equal '123-123-1234', other.submitter_phone
    assert_equal 'Auntie McGee', other.nominee_name
    assert_equal 'Trump Towers', other.nominee_work_place
    assert_equal 'auntie@mcgee.org', other.nominee_email
    assert_equal '432-432-4321', other.nominee_phone
    assert_equal 'Ronald McDonald', other.nominee_title
    assert_equal 'Hire Hamburgalur', other.why_nominate
    assert_equal 'change_makers', other.sdg_pioneer_role
  end

end
