class CopStatusUpdater
  def update_all
    move_active_organizations_to_noncommunicating
    move_noncommunicating_organizations_to_delisted
  end
  
  def move_active_organizations_to_noncommunicating
    organizations = Organization.about_to_become_noncommunicating
    organizations.each { |org| org.communication_late }
  end
  
  def move_noncommunicating_organizations_to_delisted
    organizations = Organization.about_to_become_delisted
    organizations.each { |org| org.delist }
  end
end