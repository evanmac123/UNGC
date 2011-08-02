class AddFeesColumnsToLocalNetworks < ActiveRecord::Migration
  def self.up
    add_column :local_networks, :fees_participant,               :boolean
    add_column :local_networks, :fees_amount_company,            :integer
    add_column :local_networks, :fees_amount_sme,                :integer
    add_column :local_networks, :fees_amount_other_organization, :integer
    add_column :local_networks, :fees_amount_participant,        :integer
    add_column :local_networks, :fees_amount_voluntary_private,  :integer
    add_column :local_networks, :fees_amount_voluntary_public,   :integer
  end

  def self.down
    remove_column :local_networks, :fees_participant
    remove_column :local_networks, :fees_amount_company
    remove_column :local_networks, :fees_amount_sme
    remove_column :local_networks, :fees_amount_other_organization
    remove_column :local_networks, :fees_amount_participant
    remove_column :local_networks, :fees_amount_voluntary_private
    remove_column :local_networks, :fees_amount_voluntary_public
  end
end
