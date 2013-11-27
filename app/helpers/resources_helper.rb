module ResourcesHelper

  def languages_for_select(selected_language=nil)
    languages = ResourceLink.includes(:language).joins(:resource).where("resources.approval='approved'").group('languages.id').select(:language_id).map{ |c| [c.language.name, c.language_id] }
    options_for_select(languages, selected: selected_language)
  end

  def resource_sort_by
    options = [
      ["Sort by Year", url_for(params.merge(:order => "year desc"))],
      # ["Sort by Year (oldest)", url_for(params.merge(:order => "year asc"))],
      ["Sort by Title", url_for(params.merge(:order => "title asc"))]
    ]
    selected = url_for(params.merge(:order => params[:order]))
    select_tag :per_page, options_for_select(options, :selected => selected), :class => 'autolink'
  end

  def approval_name(resource)
    case resource.approval
    when 'pending'
      'Pending review'
    when 'approved'
      'Approved'
    when 'previously'
      'Revoked'
    else
      'Unknown'
    end
  end

  def approver_name(resource)
    Contact.find(resource.approved_by_id).first_name rescue 'Unknown'
  end
  
  def status_date(resource)
    resource.approved? ? resource.approved_at : resource.updated_at
  end
  
  def resource_sort_field(status)
    status == :approved ? 'approved_at' : 'updated_at'
  end

  def link_to_all_resources(reference)
    link_to 'View All Resources', resources_path(commit: 'search', resource_search: { topic: {principle_ids: [Principle.find_by_reference(reference)]}}), class: 'view-all-resources'
  end

end
