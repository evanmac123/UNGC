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

require 'test_helper'

class NonBusinessOrganizationRegistrationTest < ActiveSupport::TestCase
  should belong_to :organization

  should "limit length of mission statement" do
    statement = "A" * 1001
    reg = NonBusinessOrganizationRegistration.new(mission_statement: statement)
    assert !reg.valid?
    reg = NonBusinessOrganizationRegistration.new(mission_statement: "hi")
    reg.valid?
    assert reg.valid?
  end
end
