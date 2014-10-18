class CreateContributionDescriptions < ActiveRecord::Migration
  def change
    create_table :contribution_descriptions do |t|
      t.references :local_network, null: false
      t.text :pledge
      t.text :pledge_continued
      t.text :payment
      t.text :contact
      t.text :additional

      t.timestamps
    end
    add_index :contribution_descriptions, :local_network_id
  end
end
