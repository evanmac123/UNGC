module Admin::PagesHelper
  
  def sections
    homes_children = Page.approved.find(:all, conditions: { parent_id: nil, group_id: nil }, order: 'position ASC')
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
  
  def page_for_json(page, leaves)
    opacity  = page.display_in_navigation ? '' : 'hidden'
    approval = page.approval
    children = leaves[page.id] if page.id
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
