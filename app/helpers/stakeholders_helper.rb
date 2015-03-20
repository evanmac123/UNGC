module StakeholdersHelper

  def stakeholders(filter_type=nil)
    @stakeholders ||= {}
    unless @stakeholders[filter_type]
      @stakeholders[filter_type] = if filter_type
        Organization.participants.by_type(filter_type).includes(:country).order(:name).load
      else
        Organization.includes(:country).load
      end
    end
    @stakeholders[filter_type]
  end

end
