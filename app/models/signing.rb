# == Schema Information
#
# Table name: signings
#
#  id              :integer(4)      not null, primary key
#  old_id          :integer(4)
#  initiative_id   :integer(4)
#  organization_id :integer(4)
#  added_on        :date
#  created_at      :datetime
#  updated_at      :datetime
#

class Signing < ActiveRecord::Base
  validates_presence_of :organization_id

  belongs_to :initiative
  belongs_to :signatory, :class_name => 'Organization', :foreign_key => :organization_id
  belongs_to :organization

  default_scope :order => 'added_on DESC'
end
