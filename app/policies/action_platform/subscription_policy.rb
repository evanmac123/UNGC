class ActionPlatform::SubscriptionPolicy

  attr_reader :subscription

  def initialize(subscription)
    @subscription = subscription
  end

  def can_create?(contact)
    is_manager?(contact) ||
        contact.organization_id == subscription.organization_id
  end

  def can_view?(contact)
    contact.from_ungc? ||
        contact.organization_id == subscription.organization_id
  end

  def can_edit?(contact)
    is_manager?(contact)
  end

  def can_destroy?(contact)
    is_manager?(contact) unless subscription.active?
  end

  private

  def is_manager?(contact)
    contact.is?(Role.action_platform_manager) ||
        contact.is?(Role.website_editor) ||
        contact&.id == subscription.organization.participant_manager&.id
  end
end
