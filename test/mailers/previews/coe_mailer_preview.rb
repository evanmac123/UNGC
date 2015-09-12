require './db/example_data'

class CoeMailerPreview < ActionMailer::Preview

  def example
    CoeMailer.example(organization, cop, user)
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
