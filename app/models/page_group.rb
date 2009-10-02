# == Schema Information
#
# Table name: page_groups
#
#  id                    :integer(4)      not null, primary key
#  name                  :string(255)
#  display_in_navigation :boolean(1)
#  slug                  :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#

class PageGroup < ActiveRecord::Base
  has_many :children, :class_name => 'Page', :foreign_key => :group_id
  
  named_scope :for_navigation, :conditions => ["page_groups.display_in_navigation = ?", true]
  
  def link_to_first_child
    children.first.path
  end
  
  def path
    link_to_first_child
  end
  
  def title
    name
  end
  
  
end
