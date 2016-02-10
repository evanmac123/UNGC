require 'test_helper'

class ContactPolicyTest < ActiveSupport::TestCase

  setup do
    @ungc_contact = stub_contact(from_ungc?: true)
    @network_contact = stub_contact(from_network?: true, is?: true)
    @network_contact_2 = stub_contact(from_network?: true, is?: true)
    @network_contact_person = stub_contact(from_network?: true, is?: true)
    @network_contact_person_2 = stub_contact(from_network?: true, is?: true)
    @organization_contact = stub_contact(from_organization?: true, organization_id: 1)
    @organization_contact_2 = stub_contact(from_organization?: true, organization_id: 2)

    @ungc_contact_policy = ContactPolicy.new(@ungc_contact)
    @network_contact_policy = ContactPolicy.new(@network_contact)
    @network_contact_person_policy = ContactPolicy.new(@network_contact_person)
    @organization_contact_policy = ContactPolicy.new(@organization_contact)
  end

  context 'can upload image?' do
    context 'UNGC contact policy' do
      should 'allow image upload for UNGC contacts' do
        assert @ungc_contact_policy.can_upload_image?(@ungc_contact)
      end

      should 'allow image upload for network contacts' do
        assert @ungc_contact_policy.can_upload_image?(@network_contact)
      end

      should 'allow image upload for organization contacts' do
        assert @ungc_contact_policy.can_upload_image?(@organization_contact)
      end
    end

    context 'network contact policy' do
      should 'not allow image upload for UNGC contacts' do
        assert_not @network_contact_policy.can_upload_image?(@ungc_contact)
      end

      should 'allow image upload for associated network contacts' do
        @network_contact.stubs(belongs_to_network?: true)
        assert @network_contact_policy.can_upload_image?(@network_contact)
      end

      should 'not allow image upload for unassociated network contacts' do
        assert_not @network_contact_policy.can_upload_image?(@network_contact_2)
      end

      should 'not allow image upload for organization contacts' do
        assert_not @network_contact_policy.can_upload_image?(@organization_contact)
      end
    end

    context 'organization contact policy' do
      should 'not allow image upload for UNGC contacts' do
        assert_not @organization_contact_policy.can_upload_image?(@ungc_contact)
      end

      should 'not allow image upload for associated network contacts' do
        assert_not @organization_contact_policy.can_upload_image?(@network_contact)
      end

      should 'not allow image upload for organization contacts' do
        assert_not @organization_contact_policy.can_upload_image?(@organization_contact)
      end
    end
  end

  context 'can create?' do
    context 'UNGC contact policy' do
      should 'allow creation of UNGC contacts' do
        assert @ungc_contact_policy.can_create?(@ungc_contact)
      end

      should 'allow creation of network contacts' do
        assert @ungc_contact_policy.can_create?(@network_contact)
      end

      should 'allow creation of organization contacts' do
        assert @ungc_contact_policy.can_create?(@organization_contact)
      end
    end

    context 'network contact policy' do
      should 'not allow creation of UNGC contacts' do
        assert_not @network_contact_policy.can_create?(@ungc_contact)
      end

      should 'allow creation of associated network contacts' do
        cp_from_ln = stub_contact(from_network?: true, is?: true)
        new_cp = stub_contact(from_network?: true, belongs_to_network?: true)
        policy = ContactPolicy.new(cp_from_ln)

        assert policy.can_create?(new_cp)
      end

      should 'not allow creation of unassociated network contacts' do
        assert_not @network_contact_policy.can_create?(@network_contact_2)
      end

      should 'not allow creation of organization contacts' do
        assert_not @network_contact_policy.can_create?(@organization_contact)
      end
    end

    context 'network contact person policy' do
      should 'not allow creation of UNGC contacts' do
        assert_not @network_contact_person_policy.can_create?(@ungc_contact)
      end

      should 'allow creation of associated network contacts' do
        network_contact_person_from_ln = stub_contact(from_network?: true, is?: true)
        new_contact_person = stub_contact(from_network?: true, belongs_to_network?: true)
        policy = ContactPolicy.new(network_contact_person_from_ln)

        assert policy.can_create?(new_contact_person)
      end

      should 'not allow creation of unassociated network contacts' do
        assert_not @network_contact_person_policy.can_create?(@network_contact_person_2)
      end

      should 'not allow creation of organization contacts' do
        assert_not @network_contact_person_policy.can_create?(@organization_contact)
      end
    end

    context 'organization contact policy' do
      should 'not allow creation of UNGC contacts' do
        assert_not @organization_contact_policy.can_create?(@ungc_contact)
      end

      should 'not allow creation of network contacts' do
        assert_not @organization_contact_policy.can_create?(@network_contact)
      end

      should 'allow creation of associated organization contacts' do
        assert @organization_contact_policy.can_create?(@organization_contact)
      end

      should 'not allow creation of unassociated organization contacts' do
        assert_not @organization_contact_policy.can_create?(@organization_contact_2)
      end
    end
  end

  context 'can update?' do

    should 'allow a user to update themselves' do
      contact = create_contact
      policy = ContactPolicy.new(contact)
      assert policy.can_update?(contact)
    end

    context 'UNGC contact policy' do
      should 'allow update of UNGC contacts' do
        assert @ungc_contact_policy.can_update?(@ungc_contact)
      end

      should 'allow update of network contacts' do
        assert @ungc_contact_policy.can_update?(@network_contact)
      end

      should 'allow update of organization contacts' do
        assert @ungc_contact_policy.can_update?(@organization_contact)
      end
    end

    context 'network contact policy' do
      should 'not allow update of UNGC contacts' do
        assert_not @network_contact_policy.can_update?(@ungc_contact)
      end

      should 'allow update of associated network contacts' do
        @network_contact.stubs(belongs_to_network?: true)
        assert @network_contact_policy.can_update?(@network_contact)
      end

      should 'not allow update of unassociated network contacts' do
        assert_not @network_contact_policy.can_update?(@network_contact_2)
      end

      should 'not allow update of organization contacts' do
        assert_not @network_contact_policy.can_update?(@organization_contact)
      end
    end

    context 'network contact person policy' do
      should 'not allow update of UNGC contacts' do
        assert_not @network_contact_person_policy.can_update?(@ungc_contact)
      end

      should 'allow update of associated network contacts' do
        @network_contact_person.stubs(belongs_to_network?: true)
        assert @network_contact_person_policy.can_update?(@network_contact_person)
      end

      should 'not allow update of unassociated network contacts' do
        assert_not @network_contact_person_policy.can_update?(@network_contact_person_2)
      end

      should 'not allow update of organization contacts' do
        assert_not @network_contact_person_policy.can_update?(@organization_contact)
      end
    end

    context 'organization contact policy' do
      should 'not allow update of UNGC contacts' do
        assert_not @organization_contact_policy.can_update?(@ungc_contact)
      end

      should 'not allow update of network contacts' do
        assert_not @organization_contact_policy.can_update?(@network_contact)
      end

      should 'allow update of associated organization contacts' do
        assert @organization_contact_policy.can_update?(@organization_contact)
      end

      should 'not allow update of unassociated organization contacts' do
        assert_not @organization_contact_policy.can_update?(@organization_contact_2)
      end
    end
  end


  context 'can destroy?' do
    context 'UNGC contact policy' do

      should 'allow destroy of UNGC contacts' do
        other_ungc_contact = stub_contact(from_ungc?: true)
        assert @ungc_contact_policy.can_destroy?(other_ungc_contact)
      end

      should 'allow destroy of network contacts' do
        assert @ungc_contact_policy.can_destroy?(@network_contact)
      end

      should 'allow destroy of organization contacts' do
        assert @ungc_contact_policy.can_destroy?(@organization_contact)
      end

      should 'not allow destroying oneself' do
        assert_not @ungc_contact_policy.can_destroy?(@ungc_contact)
      end
    end

    context 'network contact policy' do

      should 'not allow destroy of UNGC contacts' do
        contact = stub_contact(from_network?: true, is?: true)
        target =  stub_contact(from_ungc?: true)

        policy = ContactPolicy.new(contact)
        assert_not policy.can_destroy?(target)
      end

      should 'allow destroy of associated network contacts' do
        # two contacts from the same network
        contact = stub_contact(from_network?: true, is?: true)
        target =  stub_contact(belongs_to_network?: true)

        policy = ContactPolicy.new(contact)
        assert policy.can_destroy?(target)
      end

      should 'not allow destroy of unassociated network contacts' do
        # two contacts from different networks
        contact = stub_contact(from_network?: true, is?: true)
        target =  stub_contact(from_network?: true, belongs_to_network?: false)

        policy = ContactPolicy.new(contact)
        assert_not policy.can_destroy?(target)
      end

      should 'allow destroy of associated organization contacts' do
        # two contacts from the same participant organization
        contact = stub_contact(from_organization?: true, organization_id: 123,
                               organization: stub(participant?: true))
        target =  stub_contact(from_organization?: true, organization_id: 123)

        policy = ContactPolicy.new(contact)
        assert policy.can_destroy?(target)
      end

      should 'not allow destroy of unassociated organization contacts' do
        # two organization contacts from different organizations
        contact = stub_contact(from_organization?: true, organization_id: 123)
        target =  stub_contact(from_organization?: true, organization_id: 321)

        policy = ContactPolicy.new(contact)
        assert_not policy.can_destroy?(target)
      end
    end

    context 'network contact person policy' do

      should 'not allow destroy of UNGC contacts' do
        contact_person = stub_contact(from_network?: true, is?: true)
        target =  stub_contact(from_ungc?: true)

        policy = ContactPolicy.new(contact_person)
        assert_not policy.can_destroy?(target)
      end

      should 'allow destroy of associated network contacts' do
        # two contacts from the same network
        contact_person = stub_contact(from_network?: true, is?: true)
        target =  stub_contact(belongs_to_network?: true)

        policy = ContactPolicy.new(contact_person)
        assert policy.can_destroy?(target)
      end

      should 'not allow destroy of unassociated network contacts' do
        # two contacts from different networks
        contact_person = stub_contact(from_network?: true, is?: true)
        target =  stub_contact(from_network?: true, belongs_to_network?: false)

        policy = ContactPolicy.new(contact_person)
        assert_not policy.can_destroy?(target)
      end

      should 'allow destroy of associated organization contacts' do
        # two contacts from the same participant organization
        contact_person = stub_contact(from_organization?: true, organization_id: 123,
                               organization: stub(participant?: true))
        target =  stub_contact(from_organization?: true, organization_id: 123)

        policy = ContactPolicy.new(contact_person)
        assert policy.can_destroy?(target)
      end

      should 'not allow destroy of unassociated organization contacts' do
        # two organization contacts from different organizations
        contact_person = stub_contact(from_organization?: true, organization_id: 123)
        target =  stub_contact(from_organization?: true, organization_id: 321)

        policy = ContactPolicy.new(contact_person)
        assert_not policy.can_destroy?(target)
      end
    end


    context 'organization contact policy' do
      should 'not allow destroy of UNGC contacts' do
        contact = stub_contact(from_organization?: true)
        target =  stub_contact(from_ungc?: true)

        policy = ContactPolicy.new(contact)
        assert_not policy.can_destroy?(target)
      end

      should 'not allow destroy of network contacts' do
        contact = stub_contact(from_organization?: true)
        target =  stub_contact(from_network?: true)

        policy = ContactPolicy.new(contact)
        assert_not policy.can_destroy?(target)
      end

      should 'allow destroy of associated organization contacts' do
        contact = stub_contact(from_organization?: true, organization_id: 123)
        target =  stub_contact(from_organization?: true, organization_id: 123)

        policy = ContactPolicy.new(contact)
        assert policy.can_destroy?(target)
      end

      should 'not allow destroy of unassociated organization contacts' do
        contact = stub_contact(from_organization?: true, organization_id: 123)
        target =  stub_contact(from_organization?: true, organization_id: 321)

        policy = ContactPolicy.new(contact)
        assert_not policy.can_destroy?(target)
      end

      should 'not allow destroy of organizations by non-participant organization contacts' do
        contact = stub_contact(from_organization?: true, organization: stub(participant?: false))
        target = stub_contact

        policy = ContactPolicy.new(contact)
        assert_not policy.can_destroy?(target)
      end
    end

  end

  def stub_contact(stubs = {})
    defaults = {
      from_ungc?: false,
      from_network?: false,
      from_organization?: false,
      belongs_to_network?: false,
      local_network: nil,
      organization: stub(participant?: true)
    }
    stub(stubs.reverse_merge(defaults))
  end
end
