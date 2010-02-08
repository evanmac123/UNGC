class CopStatusUpdater
  class << self
    def update_all
      move_active_organizations_to_noncommunicating
      move_noncommunicating_organizations_to_delisted
    end

    def move_active_organizations_to_noncommunicating
      organizations = Organization.businesses.participants.active.about_to_become_noncommunicating
      organizations.each { |org| org.communication_late }
    end

    def move_noncommunicating_organizations_to_delisted
      organizations = Organization.businesses.participants.active.about_to_become_delisted
      organizations.each do |organization|
        organization.delist
        CopMailer.deliver_delisting_today(organization)
        CopMailer.deliver_delisting_today_notify_network(organization)
      end
    end
  end
end