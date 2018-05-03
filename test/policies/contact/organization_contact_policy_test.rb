require "test_helper"

class Contact::OrganizationPolicyTest < ActiveSupport::TestCase

  context '#can_upload_image? for other contacts' do
    should 'not allow image upload for other UNGC contacts' do
      contact =  create_organization_contact
      target = create_ungc_contact

      policy = ContactPolicy.new(contact)
      assert_not policy.can_upload_image?(target)
    end

    should 'not allow image upload for associated network contacts' do
      contact =  create_organization_contact
      target = create_local_network_contact

      policy = ContactPolicy.new(contact)
      assert_not policy.can_upload_image?(target)
    end

    should 'not allow image upload for organization contacts' do
      contact = create_organization_contact
      target =  create_organization_contact

      policy = ContactPolicy.new(contact)
      assert_not policy.can_upload_image?(target)
    end
  end

  context '#can_create? other contacts' do
    should 'not allow creation of UNGC contacts' do
      contact = create_organization_contact
      target =  create_ungc_contact

      policy = ContactPolicy.new(contact)
      assert_not policy.can_create?(target)
    end

    should 'not allow creation of network contacts' do
      contact = create_organization_contact
      target =  create_local_network_contact

      policy = ContactPolicy.new(contact)
      assert_not policy.can_create?(target)
    end

    should 'allow creation of associated organization contacts' do
      contact = create_organization_contact(id: 123)
      target =  create_organization_contact(id: 123)

      policy = ContactPolicy.new(contact)
      assert policy.can_create?(target)
    end

    should 'not allow creation of unassociated organization contacts' do
      contact = create_organization_contact(id: 123)
      target =  create_organization_contact(id: 456)

      policy = ContactPolicy.new(contact)
      assert_not policy.can_create?(target)
    end
  end

  context '#can_update? other contacts' do
    should 'not allow update of UNGC contacts' do
      contact = create_organization_contact
      target =  create_ungc_contact

      policy = ContactPolicy.new(contact)
      assert_not policy.can_update?(target)
    end

    should 'not allow update of network contacts' do
      contact = create_organization_contact
      target =  create_local_network_contact

      policy = ContactPolicy.new(contact)
      assert_not policy.can_update?(target)
    end

    should 'allow update of associated organization contacts' do
      contact = create_organization_contact(id: 123)
      target =  create_organization_contact(id: 123)

      policy = ContactPolicy.new(contact)
      assert policy.can_update?(target)
    end

    should 'not allow update of unassociated organization contacts' do
      contact = create_organization_contact(id: 123)
      target =  create_organization_contact(id: 456)

      policy = ContactPolicy.new(contact)
      assert_not policy.can_update?(target)
    end
  end

  context 'organization contact policy' do
    should 'not allow destroy of UNGC contacts' do
      contact = create_organization_contact
      target =  create_ungc_contact

      policy = ContactPolicy.new(contact)
      assert_not policy.can_destroy?(target)
    end

    should 'not allow destroy of network contacts' do
      contact = create_organization_contact
      target =  create_local_network_contact

      policy = ContactPolicy.new(contact)
      assert_not policy.can_destroy?(target)
    end

    should 'allow destroy of associated organization contacts' do
      contact = create_organization_contact(id: 123)
      target =  create_organization_contact(id: 123)

      policy = ContactPolicy.new(contact)
      assert policy.can_destroy?(target)
    end

    should 'not allow destroy of unassociated organization contacts' do
      contact = create_organization_contact(id: 123)
      target =  create_organization_contact(id: 456)

      policy = ContactPolicy.new(contact)
      assert_not policy.can_destroy?(target)
    end

    should 'not allow destroy of organizations by non-participant organization contacts' do
      contact = create_organization_contact(participant: false)
      target =  create_organization_contact

      policy = ContactPolicy.new(contact)
      assert_not policy.can_destroy?(target)
    end
  end

  context "#can_sign_in?" do

    should "be allowed by contacts from active organizations" do
      contact = create_organization_contact(cop_state: "active")
      policy = ContactPolicy.new(contact)

      assert policy.can_sign_in?
    end

    should "be allowed by contacts from non communicating organizations" do
      contact = create_organization_contact(cop_state: "noncommunicating")
      policy = ContactPolicy.new(contact)

      assert policy.can_sign_in?
    end

    should "be disallowed by contacts from delisted organizations that have NOT recommited" do
      contact = create_organization_contact(cop_state: "delisted")
      policy = ContactPolicy.new(contact)

      refute policy.can_sign_in?, "should not be able to sign in."
    end

    should "be allowed by contacts from delisted organizations that have recommited" do
      contact = create(:contact)
      organization = build(:delisted_participant, contacts: [contact])
      organization.recommitment_letter_file = create_file_upload
      organization.save!

      policy = ContactPolicy.new(contact)

      assert policy.can_sign_in?, "should be able to sign in."
    end
  end

  private

  def create_organization_contact(params = {})
    contact = build_stubbed(:contact)
    organization_params = params.reverse_merge(
      participant: true
    )
    contact.organization = build_stubbed(:organization, organization_params)
    contact
  end

  def create_ungc_contact
    build_stubbed(:staff_contact)
  end

  def create_local_network_contact
    contact = build_stubbed(:contact)
    contact.local_network = build_stubbed(:local_network)
    contact
  end

end
