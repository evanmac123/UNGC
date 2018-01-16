require "test_helper"

class Admin::LocalNetworksTest < ActionDispatch::IntegrationTest

  test "a staff contact sees MOUs" do
    network = create(:local_network, :with_network_contact)
    network_contact = network.contacts.first

    staff = create(:staff_contact)
    login_as(staff)

    visit admin_local_network_path(network)

    page.refute_selector("ul#main_nav li a[href='#{admin_local_network_path(network)}']", text: 'Network Management')
    page.assert_selector("ul#main_nav li a[href='#{admin_local_networks_path}']", text: 'Local Networks')
    page.assert_selector('ul.tab_nav li a[href="#profile"]', text: 'Profile')
    page.assert_selector('ul.tab_nav li a[href="#mous"]', text: 'MOUs')
    page.assert_selector('ul.tab_nav li a[href="#contacts"]', text: 'Contacts')
  end

  test "a network contact sees MOUs" do
    network = create(:local_network, :with_network_contact)
    network_contact = network.contacts.first

    login_as(network_contact)

    visit admin_local_network_path(network)

    page.assert_selector("ul#main_nav li a[href='#{admin_local_network_path(network)}']", text: 'Network Management')
    page.assert_selector("ul#main_nav li a[href='#{admin_local_networks_path}']", text: 'Local Networks')
    page.assert_selector('ul.tab_nav li a[href="#profile"]', text: 'Profile')
    page.assert_selector('ul.tab_nav li a[href="#mous"]', text: 'MOUs')
    page.assert_selector('ul.tab_nav li a[href="#contacts"]', text: 'Contacts')
  end

  test "another network contact does not see MOUs" do
    network1 = create(:local_network)

    network2 = create(:local_network, :with_executive_director)
    other_network_contact = network2.contacts.first

    login_as(other_network_contact)

    visit admin_local_network_path(network1)

    page.assert_selector("ul#main_nav li a[href='#{admin_local_network_path(network2)}']", text: 'Network Management')
    page.refute_selector("ul#main_nav li a[href='#{admin_local_networks_path}']", text: 'Local Networks')
    page.assert_selector('ul.tab_nav li a[href="#profile"]', text: 'Profile')
    page.refute_selector('ul.tab_nav li a[href="#mous"]', text: 'MOUs')
    page.refute_selector('ul.tab_nav li a[href="#contacts"]', text: 'Contacts')
  end

end
