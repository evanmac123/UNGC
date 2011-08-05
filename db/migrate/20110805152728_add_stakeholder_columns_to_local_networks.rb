class AddStakeholderColumnsToLocalNetworks < ActiveRecord::Migration
  def self.up
    add_column :local_networks, :stakeholder_company,              :boolean
    add_column :local_networks, :stakeholder_sme,                  :boolean
    add_column :local_networks, :stakeholder_business_association, :boolean
    add_column :local_networks, :stakeholder_labour,               :boolean
    add_column :local_networks, :stakeholder_un_agency,            :boolean
    add_column :local_networks, :stakeholder_ngo,                  :boolean
    add_column :local_networks, :stakeholder_foundation,           :boolean
    add_column :local_networks, :stakeholder_academic,             :boolean
    add_column :local_networks, :stakeholder_government,           :boolean
  end

  def self.down
    remove_column :local_networks, :stakeholder_company,              :boolean
    remove_column :local_networks, :stakeholder_sme,                  :boolean
    remove_column :local_networks, :stakeholder_business_association, :boolean
    remove_column :local_networks, :stakeholder_labour,               :boolean
    remove_column :local_networks, :stakeholder_un_agency,            :boolean
    remove_column :local_networks, :stakeholder_ngo,                  :boolean
    remove_column :local_networks, :stakeholder_foundation,           :boolean
    remove_column :local_networks, :stakeholder_academic,             :boolean
    remove_column :local_networks, :stakeholder_government,           :boolean
  end
end