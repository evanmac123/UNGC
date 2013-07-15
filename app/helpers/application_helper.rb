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
    block.call
    self.formats = old_formats
    nil
  end

end
