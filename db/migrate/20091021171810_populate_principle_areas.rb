class PopulatePrincipleAreas < ActiveRecord::Migration
  def self.up
    [
      'Human Rights',
      'Labour',
      'Environment',
      'Anti-Corruption'
    ].each do |string|
      p = PrincipleArea.find_by_name(string) or PrincipleArea.create(:name => string)
    end
  end

  def self.down
    puts "nothing to do"
  end
end
