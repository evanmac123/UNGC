require 'test_helper'

class SigningTest < ActiveSupport::TestCase
  should validate_presence_of :organization_id

  should belong_to :initiative
  should belong_to :signatory
  should belong_to :organization

  should "find the latest contribution time for the current year" do
    old     = create_signing_for 2010, Date.new(2014,7,1)
    newish  = create_signing_for 2013, Date.new(2014,1,1)
    newest  = create_signing_for 2013, Date.new(2014,6,1)

    assert_equal newest.updated_at, Signing.latest_contribution_update
  end

  private

  def create_signing_for(initiative_year, updated_at)
    create_organization_type
    initiative = create_initiative(name: "#{initiative_year} Foundation Contributors")
    signing = create_signing(organization: create_organization, initiative: initiative)
    signing.send(:write_attribute, :updated_at, updated_at)
    signing.save!
    signing
  end

end
