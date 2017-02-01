class OrganizationMailerPreview < ActionMailer::Preview

  def submission_received
    create_contact_point

    OrganizationMailer.submission_received(organization)
  end

  def submission_jci_referral_received
    create_ceo

    OrganizationMailer.submission_jci_referral_received(organization)
  end

  def in_review
    create_contact_point
    organization.comments << create_staff_comment

    OrganizationMailer.in_review(organization)
  end

  def in_review_local_network
    create_ceo
    create_contact_point
    create_network_report_recipient
    organization.comments << create_staff_comment

    OrganizationMailer.in_review_local_network(organization)
  end

  def network_review
    create_ceo
    create_contact_point
    create_network_report_recipient

    OrganizationMailer.network_review(organization)
  end

  def approved_business
    create_contact_point

    OrganizationMailer.approved_business(organization)
  end

  def approved_nonbusiness
    create_contact_point

    OrganizationMailer.approved_nonbusiness(organization)
  end

  def approved_local_network
    create_ceo
    create_contact_point
    create_network_report_recipient

    OrganizationMailer.approved_local_network(organization)
  end

  def approved_city
    create_ceo
    create_contact_point

    OrganizationMailer.approved_city(organization)
  end

  def reject_microenterprise
    create_contact_point

    OrganizationMailer.reject_microenterprise(organization)
  end

  def reject_microenterprise_network
    create_ceo
    create_contact_point

    OrganizationMailer.reject_microenterprise_network(organization)
  end

  def foundation_invoice
    create_contact_point

    OrganizationMailer.foundation_invoice(organization)
  end

  def foundation_reminder
    create_contact_point

    OrganizationMailer.foundation_reminder(organization)
  end

  private

  def create_ceo
    FactoryGirl.create(:contact, organization: organization,
                       roles: [Role.ceo])
  end

  def create_contact_point
    FactoryGirl.create(:contact, organization: organization,
                       roles: [Role.contact_point])
  end

  def create_network_report_recipient
    FactoryGirl.create(:contact, local_network: local_network,
                       roles: [Role.network_report_recipient])
  end

  def create_staff
    FactoryGirl.create(:contact, organization: ungc)
  end

  def organization
    @organization ||= FactoryGirl.create(:organization, country: country)
  end

  def country
    @country ||= FactoryGirl.create(:country, local_network: local_network)
  end

  def local_network
    @local_network ||= FactoryGirl.create(:local_network)
  end

  def ungc
    @ungc ||= Organization.where(name: DEFAULTS[:ungc_organization_name]).first_or_create!
  end

  def create_staff_comment
    FactoryGirl.create(:comment, body: Faker::Lorem.sentence, contact: create_staff)
  end

end
