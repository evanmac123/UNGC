class AddNoPledgeReasonToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :no_pledge_reason, :string
  end
end
