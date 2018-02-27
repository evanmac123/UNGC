require 'minitest/autorun'

module Crm
  class ActionPlatformSubscriptionSyncJobTest < ActiveJob::TestCase

    context 'jobs' do
      setup do
        Rails.configuration.x_enable_crm_synchronization = true
        TestAfterCommit.enabled = true
      end

      teardown do
        Rails.configuration.x_enable_crm_synchronization = false
        TestAfterCommit.enabled = false
      end

      should 'conditionally enqueue a job on create' do
        assert_enqueued_with(job: Crm::ActionPlatform::SubscriptionSyncJob) do
          create(:action_platform_subscription)
        end
      end

      should 'conditional enqueue an update job' do
        network = create(:action_platform_subscription)

        assert_enqueued_with(job: Crm::ActionPlatform::SubscriptionSyncJob) do
          network.update!(state: :ce_engagement_review)
        end

        assert_no_enqueued_jobs do
          network.update!(state: :ce_engagement_review)
          network.touch
        end
      end

      should 'conditionally enqueue a job on destroy' do
        subscription = create(:action_platform_subscription)

        assert_enqueued_with(job: Crm::ActionPlatform::SubscriptionSyncJob) do
          subscription.destroy!
        end
      end
    end


    test ".should_sync false" do
      model = build(:action_platform_subscription, state: :declined)
      assert Crm::ActionPlatform::SubscriptionSyncJob.perform_now(:should_sync?, model)
    end

    test ".should_sync true" do
      model = build(:action_platform_subscription, :approved)
      assert Crm::ActionPlatform::SubscriptionSyncJob.perform_now(:should_sync?, model)
    end

    test "create a subscription" do
      organization = build(:crm_organization)
      contact = build(:contact_point, :with_record_id, organization: organization)
      subscription = create(:action_platform_subscription, :approved,
                            platform: build(:crm_action_platform),
                            organization: organization,
                            contact: contact,
                            )

      crm = mock("crm")
      crm.expects(:log)

      record_id = '00x0D0000000001MVK'

      crm.expects(:create).with do |object_name, params|
        object_name == 'Action_Platform_Subscription__c' &&
            params.has_key?('Contact_Point__c') &&
            params.has_key?('Action_Platform__c') &&
            params.has_key?('Organization__c')
      end.returns(record_id)

      subscription = subscription.reload
      assert_nil subscription.record_id

      Crm::ActionPlatform::SubscriptionSyncJob.perform_now(:create, subscription, nil, crm)

      refute_nil subscription.reload.record_id
      assert_equal record_id, subscription.record_id
    end

    test "create a subscription with unsynced parents" do
      organization = create(:organization, :with_sector)
      contact = create(:contact_point, organization: organization)
      platform = create(:action_platform_platform)

      crm_subscription = create(:action_platform_subscription, :approved,
                            platform: platform, organization: organization, contact: contact)

      crm = mock("crm")
      crm.expects(:log).with("creating Action_Platform__c-(#{platform.id}) ActionPlatform::Platform")
      crm.expects(:log).with("creating Action_Platform_Subscription__c-(#{crm_subscription.id}) ActionPlatform::Subscription")
      crm.expects(:log).with("creating Contact-(#{contact.id}) Contact")
      crm.expects(:log).with("creating Account-(#{organization.id}) Organization")


      record_id = '00x0D0000000001MVK'
      platform_record_id = '0605D0000000001MVK'
      org_record_id = '0010D0000000001MVK'
      contact_record_id = '0030D0000000001MVK'

      crm.expects(:find).with("Action_Platform__c", platform.id.to_s, 'UNGC_Action_Platform_ID__c').returns(nil)
      crm.expects(:create).with("Action_Platform__c", anything).returns(platform_record_id)
      crm.expects(:find).with("Account", organization.id.to_s, "UNGC_ID__c").returns(nil, nil, nil, Restforce::SObject.new(Id: org_record_id))
      crm.expects(:create).with("Account", anything).returns(org_record_id)
      crm.expects(:find).with("Contact", contact.id.to_s, "UNGC_Contact_ID__c")
      crm.expects(:create).with("Contact", anything).returns(contact_record_id)
      crm.expects(:create).with do |object_name, params|
        object_name == 'Action_Platform_Subscription__c' &&
            params.has_key?('Contact_Point__c') &&
            params.has_key?('Action_Platform__c') &&
            params.has_key?('Organization__c')
      end.returns(record_id)

      assert_nil crm_subscription.organization.record_id
      assert_nil crm_subscription.contact.record_id
      assert_nil crm_subscription.platform.record_id
      assert_nil crm_subscription.record_id

      Crm::ActionPlatform::SubscriptionSyncJob.perform_now(:create, crm_subscription, nil, crm)

      crm_subscription.reload

      assert_equal org_record_id, crm_subscription.organization.record_id
      assert_equal contact_record_id, crm_subscription.contact.record_id
      assert_equal platform_record_id, crm_subscription.platform.record_id
      assert_equal record_id, crm_subscription.record_id
    end

    test "create a subscription with synced parents" do
      organization = create(:crm_organization)
      contact = create(:contact_point, :with_record_id, organization: organization)
      platform = create(:crm_action_platform)

      subscription = create(:action_platform_subscription, :approved,
                            platform: platform, organization: organization, contact: contact, record_id:  nil)

      crm = mock("crm")
      crm.expects(:log).with("creating Action_Platform_Subscription__c-(#{subscription.id}) ActionPlatform::Subscription")

      record_id = '00x0D0000000001MVK'
      crm.expects(:create).with do |object_name, params|
        object_name == 'Action_Platform_Subscription__c' &&
            params.has_key?('Created_at__c') &&
            params['Contact_Point__c'] == contact.record_id &&
            params['Action_Platform__c'] == platform.record_id &&
            params['Organization__c'] = organization.record_id
      end.returns(record_id)

      refute_nil organization.record_id
      refute_nil contact.record_id
      refute_nil platform.record_id
      assert_nil subscription.record_id

      Crm::ActionPlatform::SubscriptionSyncJob.perform_now(:create, subscription, nil, crm)

      refute_nil organization.reload.record_id
      refute_nil contact.reload.record_id
      refute_nil platform.reload.record_id
      refute_nil subscription.reload.record_id

      assert_equal record_id, subscription.record_id
    end

    test "update a synced subscription" do
      organization = build(:crm_organization)
      contact = build(:contact_point, :with_record_id, organization: organization)
      subscription = build(:crm_action_platform_subscription, :approved,
                            platform: build(:crm_action_platform),
                            organization: organization,
                            contact: contact,
                            )
      changes = subscription.changes
      subscription.save!


      crm = mock("crm")
      crm.expects(:log).with("updating Action_Platform_Subscription__c-(#{subscription.id}) ActionPlatform::Subscription")

      record_id = subscription.record_id
      crm.expects(:update).with do |object_name, record_id, params|
        object_name == 'Action_Platform_Subscription__c' &&
            !params.has_key?('Contact_Point__c') &&
            !params.has_key?('Action_Platform__c') &&
            !params.has_key?('Organization__c')
      end.returns(record_id)

      refute_nil subscription.record_id

      Crm::ActionPlatform::SubscriptionSyncJob.perform_now(:update, subscription, changes, crm)

      refute_nil subscription.reload.record_id

      assert_equal record_id, subscription.record_id
    end

    test "update a subscription with unsynced parents" do
      organization = create(:organization, :with_sector)
      contact = create(:contact_point, organization: organization)
      platform = create(:action_platform_platform)

      subscription = build(:crm_action_platform_subscription, :approved,
                            platform: platform, organization: organization, contact: contact)
      changes = subscription.changes
      subscription.save!

      crm = mock("crm")
      crm.expects(:log).with("creating Action_Platform__c-(#{platform.id}) ActionPlatform::Platform")
      crm.expects(:log).with("updating Action_Platform_Subscription__c-(#{subscription.id}) ActionPlatform::Subscription")
      crm.expects(:log).with("creating Contact-(#{contact.id}) Contact")
      crm.expects(:log).with("creating Account-(#{organization.id}) Organization")


      record_id = subscription.record_id
      platform_record_id = '0605D0000000001MVK'
      org_record_id = '0010D0000000001MVK'
      contact_record_id = '0030D0000000001MVK'

      crm.expects(:find).with("Action_Platform__c", platform.id.to_s, 'UNGC_Action_Platform_ID__c').returns(nil)
      crm.expects(:create).with("Action_Platform__c", anything).returns(platform_record_id)
      crm.expects(:find).with("Account", organization.id.to_s, "UNGC_ID__c").returns(nil, nil, nil, Restforce::SObject.new(Id: org_record_id))
      crm.expects(:create).with("Account", anything).returns(org_record_id)
      crm.expects(:find).with("Contact", contact.id.to_s, "UNGC_Contact_ID__c")
      crm.expects(:create).with("Contact", anything).returns(contact_record_id)
      crm.expects(:update).with do |object_name, record_id, params|
        object_name == 'Action_Platform_Subscription__c' &&
            !params.has_key?('Created_at__c') &&
            !params.has_key?('UNGC_AP_Subscription_ID__c') &&
            params['Action_Platform__c'] == platform_record_id &&
            params['Contact_Point__c'] == contact_record_id
          # Organization got synced with the unsynced Contact
      end.returns(Restforce::SObject.new(Id: record_id))

      assert_nil organization.record_id
      assert_nil contact.record_id
      assert_nil platform.record_id
      refute_nil subscription.record_id

      Crm::ActionPlatform::SubscriptionSyncJob.perform_now(:update, subscription, changes, crm)

      refute_nil organization.reload.record_id
      refute_nil contact.reload.record_id
      refute_nil platform.reload.record_id
      refute_nil subscription.reload.record_id

      assert_equal record_id, subscription.record_id
    end

    test "update a subscription with unsynced platform" do
      organization = create(:crm_organization)
      contact = create(:contact_point, :with_record_id, organization: organization)
      platform = create(:action_platform_platform)

      subscription = build(:crm_action_platform_subscription, :approved,
                            platform: platform, organization: organization, contact: contact)
      changes = subscription.changes
      subscription.save!

      crm = mock("crm")
      crm.expects(:log).with("creating Action_Platform__c-(#{platform.id}) ActionPlatform::Platform")
      crm.expects(:log).with("updating Action_Platform_Subscription__c-(#{subscription.id}) ActionPlatform::Subscription")


      record_id = subscription.record_id
      platform_record_id = '0605D0000000001MVK'

      crm.expects(:find).with("Action_Platform__c", platform.id.to_s, 'UNGC_Action_Platform_ID__c').returns(nil)
      crm.expects(:create).with("Action_Platform__c", anything).returns(platform_record_id)
      crm.expects(:update).with do |object_name, record_id, params|
        object_name == 'Action_Platform_Subscription__c' &&
            !params.has_key?('Created_at__c') &&
            !params.has_key?('UNGC_AP_Subscription_ID__c') &&
            params.has_key?('Contact_Point__c') &&
            params['Action_Platform__c'] == platform_record_id &&
            params.has_key?('Organization__c')
      end.returns(Restforce::SObject.new(Id: record_id))

      refute_nil organization.record_id
      refute_nil contact.record_id
      assert_nil platform.record_id
      refute_nil subscription.record_id

      Crm::ActionPlatform::SubscriptionSyncJob.perform_now(:update, subscription, changes, crm)

      refute_nil organization.reload.record_id
      refute_nil contact.reload.record_id
      refute_nil platform.reload.record_id
      refute_nil subscription.reload.record_id

      assert_equal record_id, subscription.record_id
    end

    test "update a subscription with unsynced organization" do
      organization = create(:organization, :with_sector)
      contact = create(:contact_point, :with_record_id, organization: organization)
      platform = create(:crm_action_platform)

      subscription = build(:crm_action_platform_subscription, :approved,
                            platform: platform, organization: organization, contact: contact)
      changes = subscription.changes
      subscription.save!

      crm = mock("crm")
      crm.expects(:log).with("updating Action_Platform_Subscription__c-(#{subscription.id}) ActionPlatform::Subscription")
      crm.expects(:log).with("creating Account-(#{organization.id}) Organization")


      record_id = subscription.record_id
      org_record_id = '0010D0000000001MVK'

      crm.expects(:find).with("Account", organization.id.to_s, "UNGC_ID__c").returns(nil, nil, nil, Restforce::SObject.new(Id: org_record_id))
      crm.expects(:create).with("Account", anything).returns(org_record_id)
      crm.expects(:update).with do |object_name, record_id, params|
        object_name == 'Action_Platform_Subscription__c' &&
            !params.has_key?('Created_at__c') &&
            !params.has_key?('UNGC_AP_Subscription_ID__c') &&
            params.has_key?('Contact_Point__c') &&
            params['Action_Platform__c'] == platform.record_id &&
            params['Organization__c'] == org_record_id &&
            params.has_key?('Action_Platform__c')
      end.returns(Restforce::SObject.new(Id: record_id))

      assert_nil organization.record_id
      refute_nil contact.record_id
      refute_nil platform.record_id
      refute_nil subscription.record_id

      Crm::ActionPlatform::SubscriptionSyncJob.perform_now(:update, subscription, changes, crm)

      refute_nil organization.reload.record_id
      refute_nil contact.reload.record_id
      refute_nil platform.reload.record_id
      refute_nil subscription.reload.record_id

      assert_equal record_id, subscription.record_id
    end

    test "update an unsynced subscription, creates the subscription" do
      organization = create(:crm_organization)
      contact = create(:contact_point, :with_record_id, organization: organization)
      platform = create(:crm_action_platform)

      subscription = build(:action_platform_subscription, :approved,
                            platform: platform, organization: organization, contact: contact)
      changes = subscription.changes
      subscription.save!

      record_id = '00x0D0000000001MVK'

      crm = mock("crm")
      crm.expects(:log).with("creating Action_Platform_Subscription__c-(#{subscription.id}) ActionPlatform::Subscription")

      crm.expects(:find).with("Action_Platform_Subscription__c", subscription.id.to_s, 'UNGC_AP_Subscription_ID__c').returns(nil)
      crm.expects(:create).with("Action_Platform_Subscription__c", anything).returns(record_id)

      assert_nil subscription.record_id

      Crm::ActionPlatform::SubscriptionSyncJob.perform_now(:update, subscription, changes, crm)

      refute_nil subscription.reload.record_id

      assert_equal record_id, subscription.record_id
    end

    test "update is skipped if nothing was updated by ActiveRecord" do
      organization = build(:crm_organization)
      contact = build(:contact_point, :with_record_id, organization: organization)
      subscription = build(:crm_action_platform_subscription, :approved,
                           platform: build(:crm_action_platform),
                           organization: organization,
                           contact: contact,
                           )


      crm = mock("crm")
      crm.expects(:log).never
      crm.expects(:update).with("Action_Platform_Subscription__c", anything).never

      Crm::ActionPlatform::SubscriptionSyncJob.perform_now(:update, subscription, nil, crm)
    end

    test "destroy a subscription" do
      subscription = create(:crm_action_platform_subscription, :approved)

      record_id = subscription.record_id

      crm = mock("crm")
      crm.expects(:log)

      refute_nil record_id

      crm.expects(:destroy).returns(nil)
      assert_nil Crm::ActionPlatform::SubscriptionSyncJob.perform_now(:destroy, nil, { record_id: [subscription.record_id, nil] }, crm)
    end
  end
end
