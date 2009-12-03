module Admin::PagesHelper
  
  def children_of(object)
    if object.id == 'home'
      Page.approved.find(:all, conditions: { parent_id: nil, group_id: nil }, order: 'position ASC')
    elsif object.is_a?(PageGroup)
      object.visible_children
    elsif object.is_a?(Page)
      object.visible_children
    end
  end
  
  def sections
    @home = OpenStruct.new(id: 'home', title: 'Home')
    # @pending = OpenStruct.new(title: 'Pending', id: 'pending')
    [@home] + PageGroup.all
  end
  
  def link_helper(object)
    title = object.title || 'Untitled'
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
