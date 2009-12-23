class CopStatusUpdater
  def update_all
    move_active_organizations_to_noncommunicating
    move_noncommunicating_organizations_to_delisted
  end
  
  def move_active_organizations_to_noncommunicating
    organizations = Organization.participants.companies_and_smes.about_to_become_noncommunicating
    organizations.each { |org| org.communication_late }
  end
  
  def move_noncommunicating_organizations_to_delisted
    organizations = Organization.participants.companies_and_smes.about_to_become_delisted
    organizations.each { |org| puts "Before: #{org.id} => #{org.cop_state} #{org.name}\n"; }
    # organizations.each { |org| org.delist }
    organizations.each { |org| puts "After: #{org.id} => #{org.cop_state} #{org.name}\n"; }
  end
end