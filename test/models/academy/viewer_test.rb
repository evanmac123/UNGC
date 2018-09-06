require "test_helper"

class Academy::ViewerTest < ActiveSupport::TestCase

  test "organization is required" do
    contact = Academy::Viewer.new(organization_id: nil)
    refute contact.save
    assert_includes contact.errors.full_messages, "Organization can't be blank"
  end

  test "country is reqiured" do
    contact = Academy::Viewer.new(country_id: nil)
    refute contact.save
    assert_includes contact.errors.full_messages, "Country can't be blank"
  end

  test "username is required" do
    contact = Academy::Viewer.new(username: nil)
    refute contact.save
    assert_includes contact.errors.full_messages, "Username can't be blank"
  end

  context "saving a new contact" do

    it "publishes an event" do
      attrs = attributes_for(:contact).merge(
        organization: create(:organization),
        country: create(:country),
        username: "username",
      )
      form = Academy::Viewer.new(attrs)

      assert form.save

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

      assert form.save
      email = OrganizationMailer.deliveries.last
      assert_equal "#{form.name} requesting to join #{organization.name}", email.subject
    end

  end

  context "when adding a username to an existing contact" do

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

      assert form.save, form.errors.full_messages

      event = EventPublisher.client.read_all_streams_backward.first
      assert event.is_a?(DomainEvents::Organization::ContactClaimedUsername)
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

      assert form.save, form.errors.full_messages
      email = OrganizationMailer.deliveries.last
      assert_equal "#{form.name} from #{organization.name} is requesting a username and password", email.subject
    end

  end

end
