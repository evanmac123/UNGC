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
  end

  context 'can update?' do

    should 'allow a user to update themselves' do
      contact = create(:contact)
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

  end

  should "staff can always sign in" do
    contact = build_stubbed(:staff_contact)
    policy = ContactPolicy.new(contact)

    assert policy.can_sign_in?
  end

  private

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
