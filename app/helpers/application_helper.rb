module ApplicationHelper
  def body_classes
    classes = []
    classes << 'editable_page' if editable_content? # TODO: Editable by the current user?
    classes << current_section.html_code if current_section
    classes << @leftnav_selected.html_code if @leftnav_selected.try(:html_code)
    classes << @subnav_selected.html_code if @subnav_selected.try(:html_code)
    classes.join(' ')
  end

  def flash_messages_for(*keys)
    keys.collect { |k| content_tag(:div, flash[k], :class => "flash #{k}") if flash[k] }.join.html_safe
  end

  def participant_search?(key)
    key == :participant && controller.class.to_s == 'ParticipantsController'
  end

  def staff_only(&block)
    yield if current_contact && current_contact.from_ungc?
  end

  def participant_manager_only(&block)
    yield if current_contact.is? Role.participant_manager
  end


  def organization_only(&block)
    yield if current_contact && current_contact.from_organization?
  end

  def dashboard_view_only
    yield if current_contact && request.env['PATH_INFO'].include?('admin')
  end

  def is_staff
    return current_contact && current_contact.from_ungc?
  end

  def link_to_attachment(object)
    if object.attachment_file_name
      link_to object.attachment_file_name, object.attachment.url
    end
  end

  def css_display_style(show)
    "display: #{show ? 'block' : 'none'}"
  end

  def link_to_current(name, url, current, opts={})
    link = link_to name, url, opts
    li_options = {}
    li_options[:class] = 'current' if current
    content_tag :li, link, li_options
  end

  def differentiation_placement(cop)
    levels = { 'learner' => "Learner Platform &#x25BA;", 'active' => "GC Active &#x25BA;", 'advanced' => "GC Advanced" }
    html = levels.map do |key, value|
      content_tag :span, value.html_safe, :style => cop.differentiation_level_public == key ? '' : 'color: #aaa'
    end
    html.join(' ').html_safe
  end

  def current_year
    Time.now.strftime('%Y').to_i
  end

  # Allows you to call a partial with a different format
  def with_format(format, &block)
    old_formats = formats
    self.formats = [format]
    content = block.call
    self.formats = old_formats
    content
  end

  def cached_page?
    @page && !@page.dynamic_content?
  end

  def retina_image(model, size, options={})
    options[:data] ||= {}
    options[:data].merge!(:at2x => model.cover_image(size, retina: true))
    image_tag model.cover_image(size), options
  end

  # TODO: Extracted from the now deleted PagesHelper. Maybe could be cleaned up later?
  def per_page_select(steps=[10,25,50,100,250])
    # ['Number of results per page', 10, 25, 50, 100]
    options = []
    steps.each do |step|
      options << ["#{step} results per page", url_for(params.merge(:page => 1, :per_page => step))]
    end
    selected = url_for(params.merge(:page => 1, :per_page => params[:per_page]))
    select_tag :per_page, options_for_select(options, :selected => selected), :class => 'autolink'
  end

  def cop_link(cop, navigation=nil)
    if navigation
      cop_detail_with_nav_path(navigation, cop.id)
    else
      show_redesign_cops_path(differentiation: cop.differentiation_level_with_default, id: cop.id)
    end
  end

  def participant_link(organization, navigation=nil)
    if navigation
      participant_with_nav_path(navigation, organization)
    else
      redesign_participant_path(organization)
    end
  end
end
