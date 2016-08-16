require 'test_helper'

class OrganizationSubmitsWithNotContactsTest < ActionDispatch::IntegrationTest

  setup {
    default_business_organization_type # creates the default Company type
    create(:listing_status, id: 2, name: 'Privately Held')
    technology = create(:sector, name: 'Technology')
    create(:sector, id: 60, parent: technology, name: "Software & Computer Services", )
    create_roles
    create(:country, id:14, name: 'Bangladesh')
  }

  # TODO make this test pass, see https://github.com/unglobalcompact/UNGC/issues/361 for details
  # test 'Bug https://github.com/unglobalcompact/UNGC/issues/361' do
  #   # step 1
  #   visit '/participation/join/application/step1/business'
  #   fill_in "Organization Name", with: "Infinity Integrated Systems Ltd"
  #   fill_in "Website", with: "http://iis-bd.com/"
  #   fill_in "Number of Employees", with: "50"
  #   select "Privately Held", from: 'Ownership'
  #   select "Software & Computer Services", from: 'Sector'
  #   select "less than USD 50 million", from: 'Annual Sales / Revenues'
  #   select 'Bangladesh', from: "Country"
  #   click_on 'Next'
  #
  #   # step 2
  #   assert_equal organization_step2_path, current_path
  #   fill_in 'Prefix', with: 'Mr'
  #   fill_in "First Name", with: "Md"
  #   fill_in "Middle Name", with: ""
  #   fill_in "Last Name", with: "Kabir"
  #   fill_in "Job Title", with: "COO"
  #   fill_in "Email", with: "humayun.kabir@iis-bd.com"
  #   fill_in "Phone", with: "+8801911540356"
  #   fill_in "Postal Address", with: "Banani"
  #   fill_in "Address Cont.", with: ""
  #   fill_in "City", with: "Dhaka"
  #   fill_in "State / Province", with: "Please Select"
  #   fill_in "ZIP / Postal Code", with: ""
  #   select "Bangladesh", from: 'Country'
  #   fill_in "Username", with: "Infinity"
  #   fill_in "Password", with: "Infinity"
  #   click_on 'Next'
  #
  #   # step 3
  #   assert_equal organization_step3_path, current_path
  #   fill_in "Prefix", with: "Ms"
  #   fill_in "First Name", with: "Zakia"
  #   fill_in "Middle Name", with: "Akter"
  #   fill_in "Last Name", with: "Akter"
  #   fill_in "Job Title", with: "CEO"
  #   fill_in "Email", with: "zakia.akter@iis-bd.com"
  #   fill_in "Phone", with: "+8801911540356"
  #   fill_in "Postal Address", with: "Banani"
  #   fill_in "Address Cont.", with: ""
  #   fill_in "City", with: "Dhaka"
  #   fill_in "State", with: "Please Select"
  #   fill_in "ZIP / Postal Code", with: ""
  #   select "Bangladesh", from: "Country"
  #   check "A welcome package in hard copy format should be sent to the Highest Level Executive's mailing address"
  #   click_on 'Next'
  #
  #   # step 4
  #   assert_equal organization_step4_path, current_path
  #   choose 'Less than USD 50 million'
  #   click_on 'Next'
  #
  #   # step 5
  #   assert_equal organization_step5_path, current_path
  #   check "The invoice should be sent to the Primary Contact Point"
  #   fill_in "Prefix", with: ""
  #   fill_in "First Name", with: ""
  #   fill_in "Middle Name", with: ""
  #   fill_in "Last Name", with: ""
  #   fill_in "Job Title", with: ""
  #   fill_in "Email", with: ""
  #   fill_in "Phone", with: ""
  #   click_on 'Next'
  #   assert_equal organization_step6_path, current_path
  #
  #   # step 1 again (possibly in another tab)
  #   visit "/participation/join/application/step1/business"
  #   fill_in "Organization Name", with: "Infinity Integrated Systems Ltd"
  #   fill_in "Website", with: "http://iis-bd.com/"
  #   fill_in "Number of Employees", with: "50"
  #   select "Privately Held", from: 'Ownership'
  #   select "Software & Computer Services", from: 'Sector'
  #   select "less than USD 50 million", from: 'Annual Sales / Revenues'
  #   select 'Bangladesh', from: "Country"
  #   click_on 'Next'
  #   assert_equal organization_step2_path, current_path
  #
  #   # step 1 yet again (possibly in another tab)
  #   visit "/participation/join/application/step1/business"
  #   fill_in "Organization Name", with: "Infinity Integrated Systems Ltd"
  #   fill_in "Website", with: "http://iis-bd.com/"
  #   fill_in "Number of Employees", with: "50"
  #   select "Privately Held", from: 'Ownership'
  #   select "Software & Computer Services", from: 'Sector'
  #   select "less than USD 50 million", from: 'Annual Sales / Revenues'
  #   select 'Bangladesh', from: "Country"
  #   click_on 'Next'
  #   assert_equal organization_step2_path, current_path
  #
  #   # step 2 again with invalid attributes (possibly in another tab)
  #   fill_in 'Prefix', with: ''
  #   fill_in "First Name", with: ""
  #   fill_in "Middle Name", with: ""
  #   fill_in "Last Name", with: ""
  #   fill_in "Job Title", with: ""
  #   fill_in "Email", with: ""
  #   fill_in "Phone", with: ""
  #   fill_in "Postal Address", with: ""
  #   fill_in "Address Cont.", with: ""
  #   fill_in "City", with: ""
  #   fill_in "State / Province", with: ""
  #   fill_in "ZIP / Postal Code", with: ""
  #   select "Bangladesh", from: 'Country'
  #   fill_in "Username", with: "Infinity"
  #   fill_in "Password", with: "Infinity"
  #   click_on 'Next'
  #   assert_equal organization_step2_path, current_path
  #
  #   # the user doesn't actually try visit step6 again, but that's
  #   # the only way we can POST to step6
  #   visit organization_step6_path
  #   # step6 will redirect to step5
  #   assert_equal organization_step5_path, current_path
  #   check "The invoice should be sent to the Primary Contact Point"
  #   fill_in "Prefix", with: ""
  #   fill_in "First Name", with: ""
  #   fill_in "Middle Name", with: ""
  #   fill_in "Last Name", with: ""
  #   fill_in "Job Title", with: ""
  #   fill_in "Email", with: ""
  #   fill_in "Phone", with: ""
  #   click_on 'Next'
  #
  #   # step 6
  #   assert_equal organization_step6_path, current_path
  #   attach_file('organization_commitment_letter', 'test/fixtures/files/untitled.pdf')
  #   click_on 'Submit'
  #
  #   # step 7
  #   assert_equal organization_step7_path, current_path
  #
  #   participant = Organization.find_by!(name:'Infinity Integrated Systems Ltd')
  #   assert_equal 2, participant.contacts.count
  # end

end
