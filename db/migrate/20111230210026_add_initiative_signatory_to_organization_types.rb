class AddInitiativeSignatoryToOrganizationTypes < ActiveRecord::Migration
  def self.up
    OrganizationType.create(:name => 'Initiative Signatory', :type_property => 0)
  end

  def self.down
    OrganizationType.delete_all("name = 'Initiative Signatory'")
  end
end
