# == Schema Information
# Schema version: 20090831192138
#
# Table name: navigations
#
#  id         :integer(4)      not null, primary key
#  label      :string(255)
#  href       :string(255)
#  parent_id  :integer(4)
#  position   :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class Navigation < ActiveRecord::Base
  has_many :children, :order => "position ASC", :class_name => 'Navigation', :foreign_key => :parent_id
  
  named_scope :sections, {
    :conditions => [
      "parent_id is null AND top_nav = ?",
      true
    ],
    :include => :children
  }
  
  def self.for_path(string)
    possible = Navigation.find_by_href(string, :include => :children)
    unless possible # it couldn't be found, but maybe it's inside a "directory"
      array = string.split('/')
      array.pop
      parent = array.join('/') + '/index.html'
      possible = for_path(parent) # recursion - can climb up until it finds a Nav element
    end
    possible
  end
  
  def is_child_of?(nav)
    !!parent_id && parent_id == nav.id
  end
  
  def parent
    return nil unless parent_id
    self.class.find_by_id parent_id
  end
  
  def parent=(nav)
    self.parent_id = nav.id
  end
  
end
