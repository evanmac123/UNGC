module ParticipantsHelper
  def countries_for_select
    options_for_select Country.all.map { |c| [c.name, c.id] }
  end

  def iconize(org)
    if org.noncommunicating?
      'inactive_icon'
    else
      'no_icon'
    end
  end
  
  def countries_list
    Country.find(params[:country]).map { |c| c.name }.sort.join(', ')
  end
  
  def organization_types_for_select
    options_for_select [ [] ] + OrganizationType.all.map { |type| [type.name, type.id] }
  end
  
  def searched_for
    returning('') do |response|
      response << " for: '#{@searched_for[:keyword]}'" unless @searched_for[:keyword].blank?
      response << " in #{countries_list}" unless @searched_for[:country].blank?
      if @searched_for[:business] == OrganizationType::BUSINESS
        response << " matching businesses only " 
      elsif @searched_for[:business] == OrganizationType::NON_BUSINESS
        organization_type = OrganizationType.find_by_id(@searched_for[:organization_type_id])
        response << " matching #{organization_type.try(:name).try(:downcase) || ''} non-businesses only "
      end
      case @searched_for[:cop_status]
      when Organization::COP_STATES[:active]
        response << " with active status "
      when Organization::COP_STATES[:inactive]
        response << ' with inactive status '
      when Organization::COP_STATES[:noncommunicating]
        response << ' with non-communicating status '
      end
    end
  end
end