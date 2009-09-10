class PopulateInitialContentTemplate < ActiveRecord::Migration
  def self.up
    ContentTemplate.find(:first) || ContentTemplate.create(:filename => 'pages/static/default.html.haml', :label => 'Standard', :default => true)
  end

  def self.down
  end
end
