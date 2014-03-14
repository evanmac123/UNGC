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

  def self.for_initiative_ids(ids)
    where("initiative_id IN (?)", Initiative.find(ids).map(&:id))
      .includes(:initiative, :organization)
      .order("initiatives.name ASC")
  end
  
  # When the last manual update of the contributor list was made
  # TODO: can be removed after the Contribution model is implemented
  def self.latest_contribution_update
    initiative_ids = Initiative.contributor_for_years([2013,2014]).map(&:id)
    latest = find_by_sql("SELECT MAX(updated_at) AS updated_at
                          FROM `signings` WHERE `initiative_id` IN (#{initiative_ids.join(",")})").first
    latest.updated_at
  end
  
end