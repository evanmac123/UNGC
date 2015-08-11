class CopStatusUpdater

  def self.update_all
    updater = self.new
    updater.move_active_organizations_to_noncommunicating
    updater.move_noncommunicating_organizations_to_delisted
  end

  def move_active_organizations_to_noncommunicating
    info "Running move_active_organizations_to_noncommunicating"
    organizations = Organization.businesses.participants.active.about_to_become_noncommunicating
    organizations.find_each do |organization|
      move_to_noncommunicating(organization)
    end
  end

  def move_noncommunicating_organizations_to_delisted
    info "Running move_noncommunicating_organizations_to_delisted"
    organizations = Organization.businesses.participants.active.about_to_become_delisted
    organizations.find_each do |organization|
      move_to_noncommunicating(organization)
      delist(organization)
    end
  end

  private

  def move_to_noncommunicating(organization)
    info "#{organization.id}: #{organization.name} is Non-Communicating"
    organization.communication_late!
  rescue => e
    error "Failed to move organization to Non-Communicating #{organization.id}:#{organization.name}", e
  end

  def delist(organization)
    organization.delist!
    info "Delisted #{organization.id}:#{organization.name}"
  rescue => e
    error "Failed to delist #{organization.id}:#{organization.name}", e
  end

  def notify_of_delisting(organization)
    CopMailer.delisting_today(organization).deliver
    info "emailed delisted #{organization.id}:#{organization.name}"
  rescue => e
    error "Could not email #{organization.id}:#{organization.name}", e
  end

  def info(message)
    log(message)
  end

  def error(message, error=nil, params={})
    log("error", message)
    Honeybadger.notify(
      error_class:    "CopStatusUpdater",
      error_message:  "#{message} #{error}",
      parameters:     params
    )
  end

  def log (method="info", string)
    @logger ||= Logger.new(File.join(Rails.root, 'log', 'cop_reminder.log'))
    @logger.send method.to_sym, "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} : #{string}"
  end

end
