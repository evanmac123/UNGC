# == Schema Information
# Schema version: 20090831192138
#
# Table name: contents
#
#  id         :integer(4)      not null, primary key
#  path       :string(255)
#  crumbs     :text
#  content    :text
#  created_at :datetime
#  updated_at :datetime
#

class Content < ActiveRecord::Base
  serialize :path
  has_many :children, :order => "position ASC", :class_name => 'Content', :foreign_key => :parent_id
  
  def self.sections
    find :all, :conditions => "parent_id is null", :include => :children
  end
  
  def parent
    return nil unless parent_id
    self.class.find :first, :conditions => ["id = ?", parent_id]
  end
  
end
