class AddReferenceToPriciples < ActiveRecord::Migration
  def change
    add_column :principles, :reference, :string
  end
end
