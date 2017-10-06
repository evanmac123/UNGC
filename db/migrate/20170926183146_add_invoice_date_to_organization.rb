class AddInvoiceDateToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :invoice_date, :date
  end
end
