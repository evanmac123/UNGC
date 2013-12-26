class AddFundingModelToLocalNetworks < ActiveRecord::Migration
  def change
    add_column :local_networks, :funding_model, :string
  end
end
