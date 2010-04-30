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

  def sectors_for_select
    sectors = Sector.participant_search_options
    options_for_select [ ['All sectors', 'all'] ] + sectors.map { |s| [s.name, s.id] }
  end
  
  def organization_types_for_select
    allowed = ["Academic", "Business Association Global", "Business Association Local", "City", "Foundation", "Labour Global", "Labour Local", "NGO Global", "NGO Local", "Public Sector Organization"]
    all = OrganizationType.all
    types = all.reject { |t| !allowed.include?(t.name) }
    options_for_select [ ['All', ''] ] + types.map { |type| [type.name, type.id] }
  end
  
  def nice_date_from_param(join_date)
    month, day, year = params[join_date].split('/')
    parsed_date = Date.parse([year,month,day].join('-'))
    parsed_date.strftime("%e&nbsp;%B,&nbsp;%Y")
  end
  
  def searched_for
    
    returning('') do |response|
      
      response << ' participants' if @searched_for[:business].blank?

      # Business search criteria
      if @searched_for[:business] == OrganizationType::BUSINESS
        response << ' business participants'
        response << " from #{countries_list}" unless @searched_for[:country_id].blank?

        if @searched_for[:sector_id].blank?
          response << ', in all sectors'
        else
          response << ", in the #{Sector.find(@searched_for[:sector_id]).name} sector"
        end

        case @searched_for[:cop_state]
          when Organization::COP_STATES[:active].to_crc32
            response << ', with an Active COP status'
          when Organization::COP_STATES[:noncommunicating].to_crc32
            response << ', with a Non-communicating COP status'
        end
      
      # Non-business search criteria
      elsif @searched_for[:business] == OrganizationType::NON_BUSINESS
        organization_type = OrganizationType.find_by_id(@searched_for[:organization_type_id])
        response << " #{organization_type.try(:name) || ''} non-business participants"
        response << " from #{countries_list}" unless @searched_for[:country_id].blank?
      end

      response << ", from #{countries_list}" unless @searched_for[:country_id].blank? || !@searched_for[:business].blank?
      
      if @searched_for[:joined_on]
        response << ", who were accepted between #{nice_date_from_param(:joined_after)} and #{nice_date_from_param(:joined_before)}"
      end
      
      response << ", matching '#{@searched_for[:keyword]}'" unless @searched_for[:keyword].blank?
      
    end
  end
  
end