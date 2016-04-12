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

  def cop_due_in_90_days
    CopMailer.cop_due_in_90_days(organization)
  end

  def cop_due_in_30_days
    CopMailer.cop_due_in_30_days(organization)
  end

  def cop_due_today
    CopMailer.cop_due_today(organization)
  end

  def cop_due_yesterday
    CopMailer.cop_due_yesterday(organization)
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
    @organization ||= FactoryGirl.create(:organization,
      country: country,
      cop_due_on: Date.today - 5.years
    ).tap do |org|
      create_contact_point(org)
    end
  end

  def cop
    @cop ||= FactoryGirl.create(:communication_on_progress, organization: organization)
  end

  def user
    @user ||= FactoryGirl.create(:contact, organization: organization)
  end

  def country
    @country ||= begin
      # create a local network and a report recipient
      network = FactoryGirl.create(:local_network)
      create_report_recipient_for(network)

      # create a country in that network
      FactoryGirl.create(:country, {
        local_network: network,
        region: 'northern_america'
      })
    end
  end

  def create_contact_point(organization)
    @contact_point_role ||= FactoryGirl.create(:role, name: Role::FILTERS[:contact_point])
    FactoryGirl.create(:contact, organization: organization, roles: [@contact_point_role])
  end

  def create_report_recipient_for(local_network)
    @network_report_recipient_role ||= FactoryGirl.create(:role, name: Role::FILTERS[:network_report_recipient])
    FactoryGirl.create(:contact, local_network: local_network, roles: [@network_report_recipient_role])
  end

end
