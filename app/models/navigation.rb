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
  # acts_as_tree :order => "position"
  has_many :children, :order => "position ASC", :class_name => 'Navigation', :foreign_key => :parent_id
  
  def self.sections
    find :all, :conditions => "parent_id is null", :include => :children
  end
  
  def parent
    return nil unless parent_id
    self.class.find :first, :conditions => ["id = ?", parent_id]
  end
  
end
