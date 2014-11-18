# == Schema Information
#
# Table name: logo_publications
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  old_id        :integer
#  parent_id     :integer
#  display_order :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class LogoPublication < ActiveRecord::Base
  validates_presence_of :name
  acts_as_tree

  default_scope lambda { order(:name) }
  scope :top_level, lambda { where('parent_id IS NULL') }
end
