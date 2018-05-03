require 'test_helper'

class Contact::LocalNetworkPolicyTest < ActiveSupport::TestCase

  should 'reject non-network contacts' do
    contact = build(:contact)
    assert_raise do
      Contact::LocalNetworkPolicy.new(contact)
    end
  end

  should 'handle permissions related to local network contacts' do
    canada = create(:local_network, name: 'canada')
    italy = create(:local_network, name: 'italy')

    assert_allows :network_report_recipient, from: canada, permission: :can_upload_image?, on_contact_from: canada
    assert_allows :network_report_recipient, from: canada, permission: :can_create?, on_contact_from: canada
    assert_allows :network_report_recipient, from: canada, permission: :can_update?, on_contact_from: canada
    assert_allows :network_report_recipient, from: canada, permission: :can_destroy?, on_contact_from: canada

    refute_allows :network_report_recipient, from: italy, permission: :can_upload_image?, on_contact_from: canada
    refute_allows :network_report_recipient, from: italy, permission: :can_create?, on_contact_from: canada
    refute_allows :network_report_recipient, from: italy, permission: :can_update?, on_contact_from: canada
    refute_allows :network_report_recipient, from: italy, permission: :can_destroy?, on_contact_from: canada

    assert_allows :network_focal_point, from: canada, permission: :can_upload_image?, on_contact_from: canada
    assert_allows :network_focal_point, from: canada, permission: :can_create?, on_contact_from: canada
    assert_allows :network_focal_point, from: canada, permission: :can_update?, on_contact_from: canada
    assert_allows :network_focal_point, from: canada, permission: :can_destroy?, on_contact_from: canada

    refute_allows :network_focal_point, from: italy, permission: :can_upload_image?, on_contact_from: canada
    refute_allows :network_focal_point, from: italy, permission: :can_create?, on_contact_from: canada
    refute_allows :network_focal_point, from: italy, permission: :can_update?, on_contact_from: canada
    refute_allows :network_focal_point, from: italy, permission: :can_destroy?, on_contact_from: canada

    assert_allows :contact_point, from: canada, permission: :can_upload_image?, on_contact_from: canada
    refute_allows :contact_point, from: canada, permission: :can_create?, on_contact_from: canada
    refute_allows :contact_point, from: canada, permission: :can_update?, on_contact_from: canada
    refute_allows :contact_point, from: canada, permission: :can_destroy?, on_contact_from: canada
  end

  should "local network contact can always sign in" do
    contact = build_stubbed(:contact)
    contact.local_network = build_stubbed(:local_network)

    policy = ContactPolicy.new(contact)
    assert policy.can_sign_in?
  end

  private

  def assert_allows(role_name, from:, permission:, on_contact_from:)
    allows?(true, role_name, from, permission, on_contact_from)
  end

  def refute_allows(role_name, from:, permission:, on_contact_from:)
    allows?(false, role_name, from, permission, on_contact_from)
  end

  def allows?(expected, role_sym, source_network, method, target_network)
    role = Role.find_by!(name: Role::FILTERS[role_sym])
    current_contact = create(:contact, roles: [role], local_network: source_network)
    target_contact = create(:contact, local_network: target_network)

    policy = Contact::LocalNetworkPolicy.new(current_contact)
    assert policy.respond_to?(method)

    is_allowed = policy.public_send(method, target_contact)

    if expected
      expected_assertion = 'allow'
      unexpected_assertion = 'denied'
    else
      expected_assertion = 'deny'
      unexpected_assertion = 'allowed'
    end

    error_message = "expected to #{expected_assertion} #{role_sym} from #{source_network.name} #{method} for a contact from #{target_network.name}, but it was #{unexpected_assertion} "

    unless expected == is_allowed
      raise Minitest::Assertion, error_message
    end
  end

end
