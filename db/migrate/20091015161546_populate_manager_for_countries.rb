class PopulateManagerForCountries < ActiveRecord::Migration
  def self.up
    managers = {
      'Nessa Whelan'  => Contact.find_by_email('whelan@un.org'),
      'Jonas Haertle' => Contact.find_by_email('haertle@un.org'),
      'Meng Liu'      => Contact.find_by_email('lium@un.org')
    }
    Country.all.each do |country|
      manager = managers[country.manager]
      if manager
        country.update_attribute :manager_id, manager.id
        puts "Manager found for #{country.name}"
      end
    end
  end

  def self.down
  end
end
