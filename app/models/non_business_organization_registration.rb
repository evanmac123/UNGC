# == Schema Information
#
# Table name: non_business_organization_registrations
#
#  id                :integer          not null, primary key
#  date              :date
#  place             :string(255)
#  authority         :string(255)
#  number            :string(255)
#  mission_statement :text
#  organization_id   :integer
#

class NonBusinessOrganizationRegistration < ActiveRecord::Base
  belongs_to :organization

  validates :number, presence: true, if: Proc.new { organization.nil? || organization.created_at > START_DATE_OF_NON_BUSINESS }
  validates :mission_statement, length: { in: 1..1000 }, if: Proc.new { organization.nil? || organization.created_at > START_DATE_OF_NON_BUSINESS }

  START_DATE_OF_NON_BUSINESS = Date.new(2013, 10, 10)
end
