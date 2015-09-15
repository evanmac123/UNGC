class CommunicationMailer < SimpleDelegator

  # provides a mailer for COE, COP or passes through a supplied mailer (for tests)
  def initialize(organization: nil, mailer: nil)
    case
    when mailer.present?
      super(mailer)
    when organization.try(:non_business?)
      super(CoeMailer)
    when organization.try(:business?)
      super(CopMailer)
    else
      raise "No mailer found"
    end
  end

end
