class AddInvoiceNumberAndCreditCardTypeToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :invoice_number, :string, length: 255
    add_column :donations, :credit_card_type, :string, length: 32
  end
end
