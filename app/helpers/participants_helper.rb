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
  
  def display_participant_status_title(organization)
    case organization.cop_state        
      when Organization::COP_STATE_DELISTED
        'Delisted on'
      else
        'Status'
    end    
  end
  
  def display_participant_status(organization)
    case organization.cop_state
      when Organization::COP_STATE_NONCOMMUNICATING
        'Non-Communicating'
      when Organization::COP_STATE_DELISTED
        yyyy_mm_dd(organization.delisted_on)
      else
        organization.cop_state.humanize
    end
  end
  
  def days_cop_overdue(organization)
    distance_of_time_in_words(Date.today, organization.cop_due_on)
  end
  
  def countries_list
    ids = params[:country]
    Country.find(params[:country]).map { |c| c.name }.sort.join(', ')
    countries = Country.find(params[:country]).map { |c| c.name }.sort
    join_items_into_sentance(countries)
  end

  def join_items_into_sentance(items)
    case items.length
      when 1
        items.first
      when 2
        items.join(' and ')
      else
        last_item = items.pop
        items.join(', ') + ' and ' + last_item
    end
  end

  def sectors_for_select
    sectors = Sector.participant_search_options
    options_for_select [ ['All sectors', 'all'] ] + sectors.map { |s| [s.name, s.id] }
  end
  
  def ownership_types_for_select
    ownership_types = ListingStatus.all
    options_for_select [ ['Any type of ownership', 'all'] ] + ownership_types.map { |s| [s.name, s.id] }
    
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
      
      # Business search criteria
      if @searched_for[:business] == OrganizationType::BUSINESS
        
        # describe type of ownership
        ownership = ''
        if @searched_for[:listing_status_id].present?
          ownership = case ListingStatus.find(@searched_for[:listing_status_id]).name.downcase
            when 'public company'
              # all FT500 companies are publicly traded
              @searched_for[:is_ft_500] ? 'FT500' : 'publicly-traded'
            when 'private company'
              'privately held'
            when 'state-owned'
              'state-owned'
          end
        end
        
        response << pluralize(@results.total_entries, ownership + ' business participant')
        response << " from #{countries_list}" unless @searched_for[:country_id].blank?

        if @searched_for[:sector_id].blank?
          response << ' in all sectors'
        else
          response << " in the #{Sector.find(@searched_for[:sector_id]).name} sector"
        end

        case @searched_for[:cop_state]
          when Organization::COP_STATES[:active].to_crc32
            response << ', with an Active COP status'
          when Organization::COP_STATES[:noncommunicating].to_crc32
            response << ', with a non-communicating COP status'
        end
      
      # Non-business search criteria
      elsif @searched_for[:business] == OrganizationType::NON_BUSINESS
        organization_type = OrganizationType.find_by_id(@searched_for[:organization_type_id])
        response << pluralize(@results.total_entries, 'non-business participant')
        response << " of type #{organization_type.try(:name) || 'unknown'}" unless @searched_for[:organization_type_id].blank?
        response << " from #{countries_list}" unless @searched_for[:country_id].blank?
      else
        response << pluralize(@results.total_entries, 'participant')
      end

      response << " from #{countries_list}" unless @searched_for[:country_id].blank? || !@searched_for[:business].blank?
      
      if @searched_for[:joined_on]
        response << ", who were accepted between #{nice_date_from_param(:joined_after)} and #{nice_date_from_param(:joined_before)}"
      end
      
      response << ", matching '#{@searched_for[:keyword]}'" unless @searched_for[:keyword].blank?
      
    end
  end
  
end