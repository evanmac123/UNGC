class AssignListingStatusToNonBusiness < ActiveRecord::Migration
  def up
    CommunicationOnProgress.transaction do
      non_business_types = OrganizationType.non_business.map(&:id).join(",")
      connection.update("update organizations set listing_status_id = 1 where organization_type_id in (#{non_business_types})")
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
