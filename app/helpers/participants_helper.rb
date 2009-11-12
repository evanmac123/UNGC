module ParticipantsHelper
  def countries_for_select
    options_for_select Country.all.map { |c| [c.name, c.id] }
  end

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