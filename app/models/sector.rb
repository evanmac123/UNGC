class Sector < ActiveRecord::Base
  validates_presence_of :name
  acts_as_tree
  
  default_scope :order => 'name'
  named_scope :top_level, :conditions => 'parent_id IS NULL'
end
