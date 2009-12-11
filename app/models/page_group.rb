# == Schema Information
#
# Table name: page_groups
#
#  id                    :integer(4)      not null, primary key
#  name                  :string(255)
#  display_in_navigation :boolean(1)
#  html_code             :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#

class PageGroup < ActiveRecord::Base
  has_many :children, :class_name => 'Page', :foreign_key => :group_id, :conditions => {:parent_id => nil}
  has_many :visible_children, 
    :class_name  => 'Page', 
    :foreign_key => :group_id, 
    :conditions  => {:approval => 'approved', :display_in_navigation => true, :parent_id => nil},
    :order       => "position ASC"
  
  named_scope :for_navigation, 
    :include    => :visible_children,
    :order      => "page_groups.position ASC",
    :conditions => ["page_groups.display_in_navigation = ?", true]
  
  def link_to_first_child
    visible_children.first.try(:path) || ''
  end
  
  def path
    link_to_first_child
  end
  
  def title
    name
  end
  
  def title=(string)
    self.name = string
  end
  
  def self.import_tree(json_string)
    TreeImporter.import_tree(json_string)
  end
  
end
