class CoeMailerPreview < ActionMailer::Preview

  def communication_on_engagement_90_days
    CoeMailer.communication_on_engagement_90_days(organization)
  end

  def communication_on_engagement_30_days
    CoeMailer.communication_on_engagement_30_days(organization)
  end

  def communication_on_engagement_1_week_before_nc
    CoeMailer.communication_on_engagement_1_week_before_nc(organization)
  end

  def communication_on_engagement_due_today
    CoeMailer.communication_on_engagement_due_today(organization)
  end

  def communication_on_engagement_nc_day_notification
    CoeMailer.communication_on_engagement_nc_day_notification(organization)
  end

  def communication_on_engagement_1_month_after_nc
    CoeMailer.communication_on_engagement_1_month_after_nc(organization)
  end

  def communication_on_engagement_9_months_before_expulsion
    CoeMailer.communication_on_engagement_9_months_before_expulsion(organization)
  end

  def communication_on_engagement_3_months_before_expulsion
    CoeMailer.communication_on_engagement_3_months_before_expulsion(organization)
  end

  def communication_on_engagement_1_month_before_expulsion
    CoeMailer.communication_on_engagement_1_month_before_expulsion(organization)
  end

  def communication_on_engagement_2_weeks_before_expulsion
    CoeMailer.communication_on_engagement_2_weeks_before_expulsion(organization)
  end

  def communication_on_engagement_1_week_before_expulsion
    CoeMailer.communication_on_engagement_1_week_before_expulsion(organization)
  end

  def delisting_today
    CoeMailer.delisting_today(organization)
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

  def country
    @country ||= begin
      # create a local network and a report recipient
      network = FactoryGirl.create(:local_network)
      create_report_recipient_for(network)

      # create a country in that network
      FactoryGirl.create(:country, local_network: network)
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
