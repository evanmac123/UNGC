class TreeImporter
  attr_accessor :title, :identifier, :children, :position, :type

  def self.get_type_and_id(tmp_identifier)
    if tmp_identifier == 'section_home'
      type_str = 'section'
      identifier = nil
    else
      type_str = tmp_identifier[/[^_0-9]+/]
      identifier = tmp_identifier[/\d+/]
    end
    [type_str, identifier]
  end
  
  def self.new_from_json(node, position=0)
    # raise node.inspect
    type_str, identifier = get_type_and_id(node['attributes']['id'])
    title = node['data']['title']
    children = []
    node['children'].each_with_index { |child,i| children << new_from_json(child, i) } if node['children']
    new title: title, identifier: identifier, type: type_str, position: position, children: children
  end
  
  def self.import_tree(string)
    data = JSON.parse string
    sections = []
    data.each_with_index do |node,i|
      sections << new_from_json(node, i)
    end
    sections.each { |s| s.save }
  end
  
  def initialize(hash)
    hash.each_pair do |key,value|
      self.send("#{key}=", value)
    end
  end
  
  def save
    if is_section?
      save_section
    else
      save_page
    end
  end
  
  def is_section?
    type['section']
  end
  
  def save_children_for_section(section=nil, parent=nil)
    ids = children.map(&:identifier)
    pages = {}
    Page.find(ids).each { |p| pages[p.id] = p }
    children.each do |child|
      id = child.identifier.to_i
      page = pages[id]
      raise "Unable to find #{id.inspect} to save #{child.inspect} in #{hash.inspect}" unless page
      child.save_page(page, section, parent)
    end
  end
  
  def save_page(page, section=nil, parent=nil)
    # FIXME: Updates pages whose titles have apostrophes and quotation marks every time, even if they haven't actually changed
    page.title = title
    page.position = position
    if section
      page.group_id = section.id
    else
      page.group_id = nil
    end
    if parent
      page.parent_id = parent.id 
    else
      page.parent_id = nil
    end
    save_children_for_section(section, page)
    page.save
  end

  def find_or_create_section
    s = PageGroup.find_by_id(identifier) if identifier 
    if s
      s.title    = title
      s.position = position
    else
      s = PageGroup.create(title: title, position: position)
      # TODO: Add path stub, html, etc.
    end
    s
  end
  
  def save_section
    s = find_or_create_section unless identifier.blank? # the 'home' section is fake, doesn't really exist
    save_children_for_section(s)
    s.save if s
  end
end
