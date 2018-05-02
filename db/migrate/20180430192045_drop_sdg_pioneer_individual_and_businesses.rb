class DropSdgPioneerIndividualAndBusinesses < ActiveRecord::Migration
  def change
    drop_table :sdg_pioneer_individuals
    drop_table :sdg_pioneer_businesses
  end
end
