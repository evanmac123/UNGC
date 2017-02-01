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
    create_contact_point

    OrganizationMailer.approved_business(organization)
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
    create_ceo
    create_contact_point

    OrganizationMailer.approved_city(organization)
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
    FactoryGirl.create(:contact, organization: organization, roles: [Role.ceo])
  end

  def create_contact_point
    FactoryGirl.create(:contact, organization: organization, roles: [Role.contact_point])
  end

  def create_network_report_recipient
    FactoryGirl.create(:contact, local_network: local_network, roles: [Role.network_report_recipient])
  end

  def create_staff
    FactoryGirl.create(:contact, organization: ungc)
  end

  def staff_user
    @staff_user ||= create_staff
  end

  def organization
    @organization ||= FactoryGirl.create(:organization, country: country).tap do |org|
      org.comments.create!(body: Faker::Lorem.sentence, contact: staff_user)
    end
  end

  def business
    @business ||= FactoryGirl.create(:business)
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

end
