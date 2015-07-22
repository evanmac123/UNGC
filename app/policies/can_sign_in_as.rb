class CanSignInAs

  def self.contact(*args)
    new(*args).authorized?
  end

  def initialize(current, target)
    @current = current
    @target = target
  end

  def authorized?
    same_local_network && from_authorized_account && to_contact_point
  end

  private

  def from_authorized_account
    @current.can_sign_in_as_contact_points?
  end

  def to_contact_point
    @target.is?(Role.contact_point)
  end

  def same_local_network
    Organization.visible_to(@current)
                .where(id: @target.organization.id)
                .any?
  end

end
