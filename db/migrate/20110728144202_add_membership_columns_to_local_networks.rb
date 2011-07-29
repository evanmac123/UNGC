class AddMembershipColumnsToLocalNetworks < ActiveRecord::Migration
  def self.up
    add_column :local_networks, :membership_subsidiaries,           :boolean
    add_column :local_networks, :membership_companies,              :integer
    add_column :local_networks, :membership_sme,                    :integer
    add_column :local_networks, :membership_micro_enterprise,       :integer
    add_column :local_networks, :membership_business_organizations, :integer
    add_column :local_networks, :membership_csr_organizations,      :integer
    add_column :local_networks, :membership_labour_organizations,   :integer
    add_column :local_networks, :membership_civil_societies,        :integer
    add_column :local_networks, :membership_academic_institutions,  :integer
    add_column :local_networks, :membership_government,             :integer
    add_column :local_networks, :membership_other,                  :integer
  end

  def self.down
    remove_column :local_networks, :membership_subsidiaries
    remove_column :local_networks, :membership_companies
    remove_column :local_networks, :membership_sme
    remove_column :local_networks, :membership_micro_enterprise
    remove_column :local_networks, :membership_business_organizations
    remove_column :local_networks, :membership_csr_organizations
    remove_column :local_networks, :membership_labour_organizations
    remove_column :local_networks, :membership_civil_societies
    remove_column :local_networks, :membership_academic_institutions
    remove_column :local_networks, :membership_government
    remove_column :local_networks, :membership_other
  end
end
