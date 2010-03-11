# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def body_classes
    returning([]) { |classes|
      classes << 'editable_page' if editable_content? # TODO: Editable by the current user?
      classes << current_section.html_code if current_section
      classes << @leftnav_selected.html_code if @leftnav_selected.try(:html_code)
      classes << @subnav_selected.html_code if @subnav_selected.try(:html_code)
      classes
    }.join(' ')
  end

  def flash_messages_for(*keys)
    keys.collect { |k| content_tag(:div, flash[k], :class => "flash #{k}") if flash[k] }.join
  end

  def participant_search?(key)
    key == :participant && controller.class.to_s == 'ParticipantsController'
  end
  
  def staff_only(&block)
    yield if logged_in? && current_user.from_ungc?
  end
  
  def organization_only(&block)
    yield if logged_in? && current_user.from_organization?
  end
  
  def link_to_attachment(object)
    if object.attachment_file_name
      link_to object.attachment_file_name, object.attachment.url
    end
  end
  
  def css_display_style(show)
    "display: #{show ? 'block' : 'none'}"
  end
  
  def link_to_current(name, url, current)
    link = link_to name, url
    li_options = {}
    li_options[:class] = 'current' if current
    content_tag :li, link, li_options
  end
  
  def current_year
    Time.now.strftime('%Y').to_i
  end

end
