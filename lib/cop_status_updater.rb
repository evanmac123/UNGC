class CopStatusUpdater
  attr_reader :logger, :mailer

  def self.update_all
    logger = BackgroundJobLogger.new('cop_reminder.log')
    self.new(logger, CopMailer).update_all
  end

  def initialize(logger, mailer)
    @logger = logger
    @mailer = mailer
  end

  def update_all
    move_active_organizations_to_noncommunicating
    move_noncommunicating_organizations_to_delisted
  end

  def move_active_organizations_to_noncommunicating
    logger.info "Running move_active_organizations_to_noncommunicating"
    organizations = Organization.businesses.participants.active.about_to_become_noncommunicating
    organizations.find_each do |organization|
      move_to_noncommunicating(organization)
    end
  end

  def move_noncommunicating_organizations_to_delisted
    logger.info "Running move_noncommunicating_organizations_to_delisted"
    organizations = Organization.businesses.participants.active.about_to_become_delisted
    organizations.find_each do |organization|
      move_to_delisted(organization)
    end
  end

  def move_to_noncommunicating(organization)
    logger.info "#{organization.id}: #{organization.name} is Non-Communicating"
    organization.communication_late!
  rescue => e
    logger.error "Failed to move organization to Non-Communicating #{organization.id}:#{organization.name}", e
  end

  def move_to_delisted(organization)
    if delist(organization)
      notify_of_delisting(organization)
    end
  end

  def delist(organization)
    organization.delist!
    logger.info "Delisted #{organization.id}:#{organization.name}"
    true
  rescue => e
    logger.error "Failed to delist #{organization.id}:#{organization.name}", e
    false
  end

  def notify_of_delisting(organization)
    mailer.delisting_today(organization).deliver
    logger.info "emailed delisted #{organization.id}:#{organization.name}"
  rescue => e
    logger.error "Could not email #{organization.id}:#{organization.name}", e
  end

end
