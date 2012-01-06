module SignatoriesHelper
  # Counts all signatories for the initiative represented by filter_type,
  # not further limited by organization type
  def count_all_signatories(filter_type=nil)
    Organization.for_initiative(filter_type).not_delisted.count
  end

  def describe_signatories(filter_type=nil)
    describe_showing_signatories % signatories(filter_type).size
    # "Caring for Climate is endorsed by %d Global Compact business participants."
  end

  def describe_showing_signatories
    if signatories_showing?(:sme)
      "%d Small and Medium-sized Companies"
    else
      "%d Large Companies"
    end
  end

  def signatories_showing?(symbol)
    if params[:sme]
      symbol == :sme
    else
      symbol == :companies
    end
  end

  def showing_signatory_type(filter_type)
    if filter_type == :climate
      # signatories_showing?(:sme) ? :sme : :companies
      :all
    else
      :all
    end
  end

  def link_to_path_if_participant(organization)
    if organization.participant?
      link_to truncate(organization.name, :length => 40), participant_path(organization)
    else
      truncate(organization.name, :length => 40)
    end
  end

  def signatories(filter_type=nil)
    @signatories ||= {}
    unless @signatories[filter_type]
      if filter_type
        if showing_signatory_type(filter_type) == :all
          scoped = Organization.for_initiative(filter_type).not_delisted
        else
          scoped = Organization.for_initiative(filter_type).by_type(showing_signatory_type(filter_type)).not_delisted
        end
      else
        scoped = Organization
      end
      @signatories[filter_type] = scoped.find(:all, :include => [:country, :sector])
    end
    @signatories[filter_type]
  end

end
