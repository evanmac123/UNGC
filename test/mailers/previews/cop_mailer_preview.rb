require './db/example_data'

class CopMailerPreview < ActionMailer::Preview

  def confirmation_blueprint
    CopMailer.confirmation_blueprint(organization, cop, user)
  end

  def confirmation_learner
    CopMailer.confirmation_learner(organization, cop, user)
  end

  def confirmation_double_learner
    CopMailer.confirmation_double_learner(organization, cop, user)
  end

  def confirmation_triple_learner_for_one_year
    CopMailer.confirmation_triple_learner_for_one_year(organization, cop, user)
  end

  def confirmation_active
    CopMailer.confirmation_active(organization, cop, user)
  end

  def confirmation_advanced
    CopMailer.confirmation_advanced(organization, cop, user)
  end

  def confirmation_non_business
    CopMailer.confirmation_non_business(organization, cop, user)
  end

  def communication_due_in_90_days
    CopMailer.communication_due_in_90_days(organization)
  end

  def communication_due_in_30_days
    CopMailer.communication_due_in_30_days(organization)
  end

  def communication_due_today
    CopMailer.communication_due_today(organization)
  end

  def communication_due_yesterday
    CopMailer.communication_due_yesterday(organization)
  end

  def delisting_in_9_months
    CopMailer.delisting_in_9_months(organization)
  end

  def delisting_in_90_days
    CopMailer.delisting_in_90_days(organization)
  end

  def delisting_in_30_days
    CopMailer.delisting_in_30_days(organization)
  end

  def delisting_in_7_days
    CopMailer.delisting_in_7_days(organization)
  end

  def delisting_today
    CopMailer.delisting_today(organization)
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

  def cop
    @cop ||= FixtureReplacement.create_communication_on_progress(organization: organization)
  end

  def user
    @user ||= FixtureReplacement.create_contact(organization: organization)
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
