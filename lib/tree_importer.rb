class TreeImporter
  attr_accessor :title, :identifier, :children, :position, :type
  
  def self.new_from_json(node, position=0)
    # raise node.inspect
    tmp_identifier = node['attributes']['id']
    if tmp_identifier == 'section_home'
      type_str = 'section'
      identifier = nil
    else
      type_str = tmp_identifier[/[^_0-9]+/]
      identifier = tmp_identifier[/\d+/]
    end
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
    type == 'section'
  end
  
  def save_page(section=nil, parent=nil)
    p = Page.find(identifier)
    p.title = title
    p.position = position
    if section
      p.group_id = section.id
    else
      p.group_id = nil
    end
    if parent
      p.parent_id = parent.id 
    else
      p.parent_id = nil
    end
    children.each do |child|
      child.save_page(section, p)
    end
    p.save
  end
  
  def save_section
    s = PageGroup.find(identifier) if identifier # the 'home' section is fake, doesn't really exist
    if s
      s.title    = title
      s.position = position
    end
    children.each do |child|
      child.save_page(s)
    end
    s.save if s
  end
end
