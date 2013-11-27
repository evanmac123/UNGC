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

  validates :date, presence: true, if: :needs_validation?
  validates :place, presence: true, if: :needs_validation?
  validates :authority, presence: true, if: :needs_validation?
  validates :mission_statement, length: { in: 1..1000 }, if: :needs_validation?

  START_DATE_OF_NON_BUSINESS = Date.new(2013, 10, 31)

  private

    def needs_validation?
      return organization.nil? || organization.created_at >= START_DATE_OF_NON_BUSINESS
    end
end
