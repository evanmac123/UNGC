require "test_helper"

class Academy::ViewerTest < ActiveSupport::TestCase

  test "organization is required" do
    contact = Academy::Viewer.new(organization_id: nil)
    success, _ = contact.submit_pending_operation
    refute success
    assert_includes contact.errors.full_messages, "Organization can't be blank"
  end

  test "country is reqiured" do
    contact = Academy::Viewer.new(country_id: nil)
    success, _ = contact.submit_pending_operation
    refute success
    assert_includes contact.errors.full_messages, "Country can't be blank"
  end

  test "username is required" do
    contact = Academy::Viewer.new(username: nil)
    success, _ = contact.submit_pending_operation
    refute success
    assert_includes contact.errors.full_messages, "Username can't be blank"
  end

  context "applying as a new contact" do

    it "publishes an event" do
      attrs = attributes_for(:contact).merge(
        organization: create(:organization),
        country: create(:country),
        username: "username",
      )
      form = Academy::Viewer.new(attrs)

      success, _ = form.submit_pending_operation
      assert success, form.errors.full_messages

      event = EventPublisher.client.read_all_streams_backward.first
      assert event.is_a?(DomainEvents::Organization::ContactRequestedMembership)
    end

    it "sends an email to the CE team" do
      organization = create(:organization)
      attrs = attributes_for(:contact).merge(
        organization: organization,
        country: create(:country),
        username: "username",
      )
      form = Academy::Viewer.new(attrs)

      success, _ = form.submit_pending_operation
      assert success, form.errors.full_messages

      email = OrganizationMailer.deliveries.last
      assert_equal "#{form.name} requesting to join #{organization.name}", email.subject
    end

  end

  context "requesting to claim a username" do

    it "publishes an event" do
      organization = create(:organization)
      contact = create(:contact, organization: organization,
        username: nil, encrypted_password: nil)

      attributes = contact.attributes.with_indifferent_access.slice(
        :email,
        :organization_id,
        :prefix,
        :job_title,
        :first_name,
        :last_name,
        :address,
        :city,
        :country_id,
        :phone,
      )

      form = Academy::Viewer.new(attributes)
      form.username = "username"

      success, _ = form.submit_pending_operation
      assert success, form.errors.full_messages

      event = EventPublisher.client.read_all_streams_backward.first
      assert event.is_a?(DomainEvents::Organization::ContactRequestedLogin)
    end

    it "sends an email to the CE team" do
      organization = create(:organization)
      contact = create(:contact, organization: organization,
        username: nil, encrypted_password: nil)

      attributes = contact.attributes.with_indifferent_access.slice(
        :email,
        :organization_id,
        :prefix,
        :job_title,
        :first_name,
        :last_name,
        :address,
        :city,
        :country_id,
        :phone,
      )

      form = Academy::Viewer.new(attributes)
      form.username = "username"

      success, _ = form.submit_pending_operation
      assert success, form.errors.full_messages

      email = OrganizationMailer.deliveries.last
      assert_equal "#{form.name} from #{organization.name} is requesting a username and password", email.subject
    end

  end

  context "for organizations whitelisted to add contacts without confirmation" do

    context "creating a new user" do

      it "creates the contact" do
        whitelisted = create(:organization, id: 7553)

        attrs = attributes_for(:contact).merge(
          organization: whitelisted,
          country: create(:country),
          username: "username",
        )
        form = Academy::Viewer.new(attrs)

        assert_difference -> { Contact.count }, +1 do
          success, _ = form.submit_pending_operation
          assert success, form.errors.full_messages
        end
      end

      it "publishes an event" do
        whitelisted = create(:organization, id: 7553)

        attrs = attributes_for(:contact).merge(
          organization: whitelisted,
          country: create(:country),
          username: "username",
        )
        form = Academy::Viewer.new(attrs)

        event_store = EventPublisher.client
        assert_difference -> { event_store.read_all_streams_forward.count }, +1 do
          success, _ = form.submit_pending_operation
          assert success, form.errors.full_messages
        end

        event = EventPublisher.client.read_all_streams_forward.last
        assert event.is_a?(DomainEvents::ContactCreated)
      end

      it "sends an email to the CE team" do
        whitelisted = create(:organization, id: 7553)

        attrs = attributes_for(:contact).merge(
          organization: whitelisted,
          country: create(:country),
          username: "username",
        )
        form = Academy::Viewer.new(attrs)

        assert_difference -> { OrganizationMailer.deliveries.count }, +2 do
          success, _ = form.submit_pending_operation
          assert success, form.errors.full_messages
        end

        email = OrganizationMailer.deliveries.to_a[-2]
        assert_equal "Request to review recent contact added to #{whitelisted.name}", email.subject
      end

      it "sends an email to the new contact with password reset instructions" do
        whitelisted = create(:organization, id: 7553)

        attrs = attributes_for(:contact).merge(
          organization: whitelisted,
          country: create(:country),
          username: "username",
        )
        form = Academy::Viewer.new(attrs)

        assert_difference -> { OrganizationMailer.deliveries.count }, +2 do
          success, _ = form.submit_pending_operation
          assert success, form.errors.full_messages
        end

        email = OrganizationMailer.deliveries.last
        assert_equal "Welcome to the UN Global Compact Academy", email.subject
      end
    end

    context "claiming a username" do

      it "updates the contact with the new username" do
        whitelisted = create(:organization, id: 7553)

        contact = create(:contact, organization: whitelisted,
                         username: nil, encrypted_password: nil)

        attributes = contact.attributes.with_indifferent_access.slice(
          :email,
          :organization_id,
          :prefix,
          :job_title,
          :first_name,
          :last_name,
          :address,
          :city,
          :country_id,
          :phone,
        )

        form = Academy::Viewer.new(attributes)
        form.username = "username"

        success, _ = form.submit_pending_operation
        assert success, form.errors.full_messages

        assert_equal "username", contact.reload.username
      end

      it "publishes an event" do
        whitelisted = create(:organization, id: 7553)

        contact = create(:contact, organization: whitelisted,
                         username: nil, encrypted_password: nil)

        attributes = contact.attributes.with_indifferent_access.slice(
          :email,
          :organization_id,
          :prefix,
          :job_title,
          :first_name,
          :last_name,
          :address,
          :city,
          :country_id,
          :phone,
        )

        form = Academy::Viewer.new(attributes)
        form.username = "username"

        event_store = EventPublisher.client
        assert_difference -> { event_store.read_all_streams_forward.count }, +1 do
          success, _ = form.submit_pending_operation
          assert success, form.errors.full_messages
        end

        event = EventPublisher.client.read_all_streams_forward.last
        assert event.is_a? DomainEvents::Organization::ContactClaimedUsername
      end

      it "sends an email to the CE team" do
        whitelisted = create(:organization, id: 7553)

        contact = create(:contact, organization: whitelisted,
                         username: nil, encrypted_password: nil)

        attributes = contact.attributes.with_indifferent_access.slice(
          :email,
          :organization_id,
          :prefix,
          :job_title,
          :first_name,
          :last_name,
          :address,
          :city,
          :country_id,
          :phone,
        )

        form = Academy::Viewer.new(attributes)
        form.username = "username"

        assert_difference -> { OrganizationMailer.deliveries.count }, +2 do
          success, _ = form.submit_pending_operation
          assert success, form.errors.full_messages
        end

        email = OrganizationMailer.deliveries.to_a[-2]
        assert_equal "#{contact.name} claimed an existing account in #{whitelisted.name}", email.subject
      end

      it "sends an email to the new contact with password reset instructions" do
        whitelisted = create(:organization, id: 7553)

        contact = create(:contact, organization: whitelisted,
                         username: nil, encrypted_password: nil)

        attributes = contact.attributes.with_indifferent_access.slice(
          :email,
          :organization_id,
          :prefix,
          :job_title,
          :first_name,
          :last_name,
          :address,
          :city,
          :country_id,
          :phone,
        )

        form = Academy::Viewer.new(attributes)
        form.username = "username"

        assert_difference -> { OrganizationMailer.deliveries.count }, +2 do
          success, _ = form.submit_pending_operation
          assert success, form.errors.full_messages
        end

        email = OrganizationMailer.deliveries.last
        assert_equal "United Nations Global Compact - Reset Password", email.subject
      end

    end

  end

end
