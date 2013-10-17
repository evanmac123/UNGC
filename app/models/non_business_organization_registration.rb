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
  validates :mission_statement, length: { minimum: 1, maximum: 1000 }

  belongs_to :organization
end
