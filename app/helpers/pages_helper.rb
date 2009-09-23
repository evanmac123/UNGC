module PagesHelper
  def paged_participants(filter_type=nil)
    unless @paged_participants 
      @paged_participants = if filter_type # FIXME: Real pagination! @jaw6
        Organization.by_type(filter_type).find(:all, :limit => 20)
      else
        Organization.find(:all, :limit => 20)
      end
    end
    @paged_participants
  end

  # Counts all signatories for the initiative represented by filter_type,
  # not further limited by organization type
  def count_all_signatories(filter_type=nil)
    Organization.for_initiative(filter_type).count
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
      signatories_showing?(:sme) ? :sme : :companies
    end
  end
  
  def signatories(filter_type=nil)
    @signatories ||= {}
    unless @signatories[filter_type]
      @signatories[filter_type] = Organization.for_initiative(filter_type).by_type(showing_signatory_type(filter_type)).find(:all, :include => [:country, :sector])
    end
    @signatories[filter_type]
  end

  def stakeholders(filter_type=nil)
    @stakeholders ||= {}
    unless @stakeholders[filter_type]
      @stakeholders[filter_type] = if filter_type
        Organization.participants.by_type(filter_type).all
      else
        Organization.find(:all)
      end
    end
    @stakeholders[filter_type]
  end

  def versioned_edit_path
    if @current_version.approved?
      edit_content_path(:id => @page)
    else
      edit_content_path(:id => @page, :version => @current_version.number)
    end
  end
end
