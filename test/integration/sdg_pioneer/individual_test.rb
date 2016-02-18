require 'test_helper'

class SdgPioneer::IndividualPioneersTest < ActionDispatch::IntegrationTest

  test 'Anonymous user submits an individual nomination' do
    create_business(name: 'Chunky Monkey')
    sdg1, _, sdg3 = 3.times.map { create_sustainable_development_goal }

    # create the landing page
    path = sdg_pioneer_index_path
    container = create_container(path: path)
    payload = new_payload(container_id: container.id)
    container.draft_payload = payload
    ContainerPublisher.new(container, create_staff_user).publish

    visit new_sdg_pioneer_individual_path

    choose  'individual_is_nominated_true'
    fill_in 'individual[nominating_organization]', with: 'Nominating Organization', visible: false
    fill_in 'individual[nominating_individual]', with: 'Nominating Individual', visible: false
    fill_in 'Name', with: 'Name'
    fill_in 'Title', with: 'Title'
    fill_in 'Email', with: 'Email'
    fill_in 'Telephone', with: 'Telephone'
    fill_in 'individual[organization_name]', with: 'Chunky Monkey'
    fill_in 'individual[local_business_nomination_name]', with: "Snoopy"
    choose  'individual_is_participant_false'
    fill_in 'individual[country_name]', with: 'Canada'
    choose  'individual_local_network_status_not_available'
    fill_in 'individual[website_url]', with: 'http://chunky-monkey.org'
    fill_in 'individual[description_of_individual]', with: 'Description'

    attach_file('individual_uploaded_supporting_documents__attachment', File.absolute_path('./test/fixtures/files/untitled.pdf'))

    check sdg1.name, visible: true
    check sdg3.name, visible: true

    fill_in 'individual[other_relevant_info]', with: 'Other_relevant_info'
    check 'individual[accepts_tou]'

    # submit the nomination
    assert_difference -> { SdgPioneer::Individual.count }, +1 do
      click_on 'Submit'
    end

    # we should be on the landing page with a notice about our submission
    assert_equal sdg_pioneer_index_path, current_path
    assert_equal I18n.t('sdg_pioneer.nominated'), find('.success-message').text

    individual = SdgPioneer::Individual.last
    assert_not_nil individual

    assert individual.is_nominated?
    assert_equal 'Nominating Organization', individual.nominating_organization
    assert_equal 'Nominating Individual', individual.nominating_individual
    assert_equal 'Name', individual.name
    assert_equal 'Title', individual.title
    assert_equal 'Email', individual.email
    assert_equal 'Telephone', individual.phone
    assert_equal 'Chunky Monkey', individual.organization_name
    assert_equal 'Snoopy', individual.local_business_nomination_name
    refute individual.is_participant?
    assert_equal 'Canada', individual.country_name
    assert_equal 'not_available', individual.local_network_status
    assert_equal 'http://chunky-monkey.org', individual.website_url
    assert_equal 'Description', individual.description_of_individual

    supporting_document = individual.supporting_documents.first
    assert_not_nil supporting_document
    assert_equal 'untitled.pdf', supporting_document.filename

    assert_equal [sdg1.id, sdg3.id], individual.matching_sdgs
    assert_equal 'Other_relevant_info', individual.other_relevant_info
    assert individual.accepts_tou?
  end

end
