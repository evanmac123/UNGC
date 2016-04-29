class SdgPioneer::Notification

  def self.notify_of_nomination(nomination)
    new(nomination).call
  end

  def initialize(nomination)
    @nomination = nomination
  end

  def call
    notify_ungc
    notify_nominee
  end

  private

  def notify_nominee
    # if we haven't already notified the nominee about their nomination
    # do so now.
    not_yet_notified = SdgPioneer::Other.
                       where(nominee_email: @nomination.nominee_email).
                       where.not(emailed_at: nil).
                       empty?

    if not_yet_notified
      SdgPioneerMailer.delay.email_nominee(@nomination.id)
    end
  end

  def notify_ungc
    SdgPioneerMailer.delay.nomination_submitted(@nomination.id)
  end

end
