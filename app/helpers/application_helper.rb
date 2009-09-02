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
end
