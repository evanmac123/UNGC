class AddAnnualContributionToLocalNetworks < ActiveRecord::Migration
  def change
    add_column :local_networks, :requires_annual_contribution, :boolean
  end
end
