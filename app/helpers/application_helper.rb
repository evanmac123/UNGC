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

  def link_to_current(name, url, current)
    link = link_to name, url
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

  # swap key/value so the values and labels for the <select> options are in the correct order
  def select_options_from_hash(hash)
    reverse_hash = Hash.new
    hash.each {|key,value|
      reverse_hash[value] = key unless reverse_hash.has_key?(key)
    }

    reverse_hash
  end

end
