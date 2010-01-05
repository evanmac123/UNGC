module ParticipantsHelper
  def countries_for_select
    options_for_select Country.all.map { |c| [c.name, c.id] }
  end

  def iconize(org)
    if org.noncommunicating?
      'alert_icon'
    else
      'no_icon'
    end
  end
  
  def countries_list
    ids = params[:country]
    Country.find(params[:country]).map { |c| c.name }.sort.join(', ')
  end
  
  def organization_types_for_select
    allowed = ["Academic", "Business Association Global", "Business Association Local", "City", "Foundation", "Labour Global", "Labour Local", "NGO Global", "NGO Local", "Public Sector Organization"]
    all = OrganizationType.all
    types = all.reject { |t| !allowed.include?(t.name) }
    options_for_select [ ['All', ''] ] + types.map { |type| [type.name, type.id] }
  end
  
  def searched_for
    returning('') do |response|
      response << " for: '#{@searched_for[:keyword]}'" unless @searched_for[:keyword].blank?
      response << " in #{countries_list}" unless @searched_for[:country_id].blank?
      if @searched_for[:business] == OrganizationType::BUSINESS
        response << " matching businesses only " 

        case @searched_for[:cop_state]
        when Organization::COP_STATES[:active].to_crc32
          response << " with active status "
        when Organization::COP_STATES[:noncommunicating].to_crc32
          response << ' with non-communicating status '
        end
      elsif @searched_for[:business] == OrganizationType::NON_BUSINESS
        organization_type = OrganizationType.find_by_id(@searched_for[:organization_type_id])
        response << " matching '#{organization_type.try(:name) || ''}' non-businesses only "
      end
    end
  end
end