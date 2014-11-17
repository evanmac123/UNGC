module StakeholdersHelper

  def stakeholders(filter_type=nil)
    @stakeholders ||= {}
    unless @stakeholders[filter_type]
      @stakeholders[filter_type] = if filter_type
        Organization.participants.by_type(filter_type).includes(:country).all(:order => :name)
      else
        Organization.includes(:country).all
      end
    end
    @stakeholders[filter_type]
  end

end
