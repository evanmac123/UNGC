class AddInvoicingColumnsToLocalNetwork < ActiveRecord::Migration
  def change
    add_column :local_networks, :business_model, :integer
    add_column :local_networks, :invoice_managed_by, :integer
    add_column :local_networks, :invoice_options_available, :integer
    add_column :local_networks, :invoice_currency, :string
  end
end
