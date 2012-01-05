# == Schema Information
#
# Table name: logo_publications
#
#  id            :integer(4)      not null, primary key
#  name          :string(255)
#  old_id        :integer(4)
#  parent_id     :integer(4)
#  display_order :integer(4)
#  created_at    :datetime
#  updated_at    :datetime
#

class LogoPublication < ActiveRecord::Base
  validates_presence_of :name
  acts_as_tree

  default_scope :order => 'name'
  named_scope :top_level, :conditions => 'parent_id IS NULL'
end
