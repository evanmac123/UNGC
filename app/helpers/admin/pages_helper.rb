require 'ostruct'

module Admin::PagesHelper
  def dynamic_json(page)
    hash = {1 => 'Dynamically generated', 0 => 'Standard'}
    if page.dynamic_content?
      hash['selected'] = '1'
    else
      hash['selected'] = '0'
    end
    hash.to_json
  end

  def enable_approval(page)
    if page.can_approve?
      ''
    else
      'disabled'
    end
  end

  def enable_revoke(page)
    if page.can_revoke?
      ''
    else
      'disabled'
    end
  end

  def page_sections
    homes_children = Page.approved.where(parent_id: nil, group_id: nil).order('position ASC').all
    @home = OpenStruct.new(id: 'home', title: 'Home', leaves: {nil => homes_children})
    [@home] + PageGroup.all
  end

  def section_for_json(section)
    opacity  = section.display_in_navigation ? '' : 'hidden'
    leaves   = section.leaves || {}
    children = leaves[nil] || []
    {
      data: {title: section.title, attributes: { class: opacity } },
      attributes: {id: "section_#{section.id}", rel: 'section'},
      children: children.map { |c| page_for_json(c, leaves) }
    }
  end

  def status_details(page)
    string = ''
    # TODO: Add details about who changed, approved, etc.
    string << "#{@page.approval.titleize}"
  end

  def page_for_json(page, leaves)
    opacity  = page.display_in_navigation ? '' : 'hidden'
    approval = page.approval
    # Children are attached to an approved parent, the tree needs to reflect their connection
    # to a new, pending version of that page
    children = leaves[page.approved_id] if page.approved_id
    children ||= []
    {
      data: {title: page.title || 'Untitled', attributes: { href: admin_page_path(page), class: "#{opacity} #{approval}"}},
      attributes: {id: "page_#{page.id}", rel: 'page'},
      children: children.map { |c| page_for_json(c, leaves) }
    }
  end

  def link_helper(object)
    title = (object.title || 'Untitled').gsub(/\&/, '&amp;')
    url = if object.is_a?(PageGroup)
      '#FIXME'
    elsif object.is_a?(Page)
      admin_page_path(object)
    else
      '#FIXME'
    end
    link_to "#{title}", url #, class: object.path == '/index.html' ? 'clicked' : ''
  end

  # depending on the user Role, return them to the appropriate page list
  def link_back_to_page_list(user)
    if user.is?(Role.website_editor)
      link_to 'Pending Pages', dashboard_path(:tab => :pages), :class => 'edit_page_large'
    elsif user.is?(Role.network_regional_manager)
      link_to 'Local Networks > Resources', local_network_resources_path, :class => 'edit_page_large'
    end
  end

  def id_for(object)
    if object.is_a?(PageGroup)
      "section_#{object.id}"
    elsif object.is_a?(Page)
      "page_#{object.id}"
    else
      object.id
    end
  end
end
