# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def body_classes
    returning([]) { |classes|
      classes << 'editable_page' if true # TODO: page_is_editable?
      classes << current_section.short if current_section
      classes << @leftnav_selected.short if @leftnav_selected.try(:short)
      classes << @subnav_selected.short if @subnav_selected.try(:short)
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
end
