# require './db/example_data'

class OrganizationMailerPreview < ActionMailer::Preview

  def submission_received
  end

  def submission_jci_referral_received
  end

  def in_review
  end

  def in_review_local_network
    create_ceo
    create_contact_point
    create_network_report_recipient

    OrganizationMailer.in_review_local_network(organization)
  end

  def network_review
    create_ceo
    create_contact_point
    create_network_report_recipient

    OrganizationMailer.network_review(organization)
  end

  def approved_business
  end

  def approved_nonbusiness
  end

  def approved_local_network
    create_ceo
    create_contact_point
    create_network_report_recipient

    OrganizationMailer.approved_local_network(organization)
  end

  def approved_city
  end

  def reject_microenterprise
  end

  def reject_microenterprise_network
  end

  def foundation_invoice
  end

  def foundation_reminder
  end

  private

  def create_ceo
    FixtureReplacement.create_contact(organization: organization, roles: [Role.ceo])
  end

  def create_contact_point
    FixtureReplacement.create_contact(organization: organization, roles: [Role.contact_point])
  end

  def create_network_report_recipient
    FixtureReplacement.create_contact(local_network: local_network, roles: [Role.network_report_recipient])
  end

  def create_staff
    FixtureReplacement.create_contact(organization: ungc)
  end

  def staff_user
    @staff_user ||= create_staff
  end

  def organization
    @organization ||= FixtureReplacement.create_organization(country: country).tap do |org|
      org.comments.create!(body: FixtureReplacement.random_string, contact: staff_user)
    end
  end

  def country
    @country ||= FixtureReplacement.create_country(local_network: local_network)
  end

  def local_network
    @local_network ||= FixtureReplacement.create_local_network
  end

  def ungc
    @ungc ||= Organization.where(name: DEFAULTS[:ungc_organization_name]).first_or_create!
  end

end
