class RemoveAnnualContributionRequiredFromLocalNetworks < ActiveRecord::Migration
  def change
    remove_column :local_networks, :requires_annual_contribution, :boolean
  end
end
