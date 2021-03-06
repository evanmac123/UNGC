# == Schema Information
#
# Table name: signings
#
#  id              :integer          not null, primary key
#  old_id          :integer
#  initiative_id   :integer
#  organization_id :integer
#  added_on        :date
#  created_at      :datetime
#  updated_at      :datetime
#

class Signing < ActiveRecord::Base
  validates_presence_of :organization_id
  validates :organization_id, :uniqueness => {:scope => :initiative_id}

  belongs_to :initiative
  belongs_to :signatory, :class_name => 'Organization', :foreign_key => :organization_id
  belongs_to :organization

end
