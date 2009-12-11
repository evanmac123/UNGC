module Admin::PagesHelper
  
  def children_of(object)
    if object.id == 'home'
      Page.approved.find(:all, conditions: { parent_id: nil, group_id: nil }, order: 'position ASC')
    elsif object.is_a?(PageGroup)
      object.approved_children.approved.find(:all, :include => {:children => :children})
    # elsif object.is_a?(Page)
    #   object.children.approved.find(:all, :include => :children)
    end
  end
  
  def sections
    @home = OpenStruct.new(id: 'home', title: 'Home')
    # @pending = OpenStruct.new(title: 'Pending', id: 'pending')
    [@home] + PageGroup.all
  end
  
  def section_for_json(section)
    opacity = section.display_in_navigation ? '' : 'hidden'
    {
      data: {title: section.title, attributes: { class: opacity } },
      attributes: {id: "section_#{section.id}", rel: 'section'},
      children: children_of(section).map { |c| page_for_json(c) }
    }
  end
  
  def page_for_json(page)
    opacity = page.display_in_navigation ? '' : 'hidden'
    {
      data: {title: page.title || 'Untitled', attributes: { href: admin_page_path(page), class: opacity}},
      attributes: {id: "page_#{page.id}", rel: 'page'},
      children: page.children.map { |c| page_for_json(c) }
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
