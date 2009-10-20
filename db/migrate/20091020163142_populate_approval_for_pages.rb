class PopulateApprovalForPages < ActiveRecord::Migration
  def self.up
    Page.find(:all, :conditions => {:approved => true}).each do |page|
      page.update_attribute :approval, :approved
    end
    Page.find(:all, :conditions => {:approved => false}).each do |page|
      page.update_attribute :approval, :previously
    end
    Page.find(:all, :conditions => {:approved => nil}).each do |page|
      page.update_attribute :approval, :pending
    end
    puts "** Not updating events at this time"
  end

  def self.down
  end
end
