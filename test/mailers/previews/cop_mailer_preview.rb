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
    @organization ||= FixtureReplacement.create_organization
  end

  def cop
    @cop ||= FixtureReplacement.create_communication_on_progress(organization: organization)
  end

  def user
    @user ||= FixtureReplacement.create_contact(organization: organization)
  end

end
