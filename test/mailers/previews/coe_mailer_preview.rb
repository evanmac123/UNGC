require './db/example_data'

class CoeMailerPreview < ActionMailer::Preview

  def example
    CoeMailer.example(organization, cop, user)
  end

  private

  def organization
    @organization ||= FixtureReplacement.create_organization(
      country: country,
      cop_due_on: Date.today - 5.years
    ).tap do |org|
      create_contact_point(org)
    end
  end

  def country
    @country ||= begin
      # create a local network and a report recipient
      network = FixtureReplacement.create_local_network
      create_report_recipient_for(network)

      # create a country in that network
      FixtureReplacement.create_country(local_network: network)
    end
  end

  def create_contact_point(organization)
    @contact_point_role ||= FixtureReplacement.create_role(name: Role::FILTERS[:contact_point])
    FixtureReplacement.create_contact(organization: organization, roles: [@contact_point_role])
  end

  def create_report_recipient_for(local_network)
    @network_report_recipient_role ||= FixtureReplacement.create_role(name: Role::FILTERS[:network_report_recipient])
    FixtureReplacement.create_contact(local_network: local_network, roles: [@network_report_recipient_role])
  end

end
