require 'test_helper'

class ContactPolicyTest < ActiveSupport::TestCase
  setup do
    @ungc_contact = stub(from_ungc?: true, from_network?: false, from_organization?: false)
    @network_contact = stub(from_ungc?: false, from_network?: true, from_organization?: false, local_network_id: 1)
    @network_contact_2 = stub(from_ungc?: false, from_network?: true, from_organization?: false, local_network_id: 2)
    @organization_contact = stub(from_ungc?: false, from_network?: false, from_organization?: true, organization_id: 1)
    @organization_contact_2 = stub(from_ungc?: false, from_network?: false, from_organization?: true, organization_id: 2)

    @ungc_contact_policy = ContactPolicy.new(@ungc_contact)
    @network_contact_policy = ContactPolicy.new(@network_contact)
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
        assert @network_contact_policy.can_create?(@network_contact)
      end

      should 'not allow creation of unassociated network contacts' do
        assert_not @network_contact_policy.can_create?(@network_contact_2)
      end

      should 'not allow creation of organization contacts' do
        assert_not @network_contact_policy.can_create?(@organization_contact)
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
        assert @network_contact_policy.can_update?(@network_contact)
      end

      should 'not allow update of unassociated network contacts' do
        assert_not @network_contact_policy.can_update?(@network_contact_2)
      end

      should 'not allow update of organization contacts' do
        assert_not @network_contact_policy.can_update?(@organization_contact)
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
end
