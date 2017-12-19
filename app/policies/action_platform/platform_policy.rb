class ActionPlatform::PlatformPolicy

  attr_reader :contact

  def initialize(contact)
    @contact = contact
  end

  def can_create?
    is_manager?
  end

  def can_view?
    contact.from_ungc?
  end

  def can_edit?
    is_manager?
  end

  def can_destroy?(platform)
    is_manager? unless platform&.subscriptions&.exists?
  end

  private

  def is_manager?
    contact.is?(Role.action_platform_manager) || contact.is?(Role.website_editor)
  end
end
