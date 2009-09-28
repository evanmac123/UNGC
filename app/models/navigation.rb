# == Schema Information
#
# Table name: navigations
#
#  id         :integer(4)      not null, primary key
#  label      :string(255)
#  href       :string(255)
#  short      :string(255)
#  parent_id  :integer(4)
#  position   :integer(4)
#  top_nav    :boolean(1)      default(TRUE)
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
    return nil if string.blank?

    unless possible # it couldn't be found, but maybe it's inside a "directory"
      # split gives us an empty first element - /second/thing/index.html becomes ["", "second", "thing", "index.html"]
      array = string.split('/')
      times_to_try = array.size - 1 # not the first empty element
      times_to_try.times do
        array.pop
        possible = Navigation.find_by_href(array.join('/') + '/index.html', :include => :children)
        return possible if possible
      end
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
