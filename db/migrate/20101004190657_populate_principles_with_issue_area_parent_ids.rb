class PopulatePrinciplesWithIssueAreaParentIds < ActiveRecord::Migration
  def self.up
    principles = { 1  => { "parent_id" => "18" },
                   2  => { "parent_id" => "18" },
                   3  => { "parent_id" => "19" },
                   4  => { "parent_id" => "19" },
                   5  => { "parent_id" => "19" },
                   6  => { "parent_id" => "19" },
                   7  => { "parent_id" => "20" },
                   8  => { "parent_id" => "20" },
                   9  => { "parent_id" => "20" },
                   10 => { "parent_id" => "21" }
                  }
    Principle.update principles.keys, principles.values
    say "Populating parent_ids"
  end

  def self.down
    Principle.update_all :parent_id => nil
    say "Deleting parent_ids"
  end
end
