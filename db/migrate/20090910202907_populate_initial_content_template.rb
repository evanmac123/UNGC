class PopulateInitialContentTemplate < ActiveRecord::Migration
  def self.up
    static  = {:filename => 'pages/static.html.haml', :label => 'Static', :default => true}
    dynamic = {:filename => 'pages/dynamic.html.haml', :label => 'Dynamic', :default => true}
    [static, dynamic].each { |t| ContentTemplate.create(t) }
  end

  def self.down
  end
end
