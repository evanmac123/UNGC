module ParticipantsHelper
  def iconize(org)
    if org.inactive?
      'alert_icon'
    elsif org.noncommunicating?
      'inactive_icon'
    else
      'no_icon'
    end
  end
end