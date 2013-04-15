class CreateAnnualReports < ActiveRecord::Migration
  def self.up
    create_table :annual_reports do |t|
      t.integer :local_network_id
      t.date :year
      t.boolean :future_plans
      t.boolean :activities
      t.boolean :financials
      t.timestamps
    end
  end

  def self.down
    drop_table :annual_reports
  end
end
