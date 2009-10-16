# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def body_classes
    returning([]) { |classes|
      classes << 'editable_page' if editable_content? # TODO: Editable by the current user?
      classes << current_section.slug if current_section
      classes << @leftnav_selected.slug if @leftnav_selected.try(:slug)
      classes << @subnav_selected.slug if @subnav_selected.try(:slug)
      classes
    }.join(' ')
  end

  def flash_messages_for(*keys)
    keys.collect { |k| content_tag(:div, flash[k], :class => "flash #{k}") if flash[k] }.join
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
end
