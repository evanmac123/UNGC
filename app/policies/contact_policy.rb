module ContactPolicy

  def self.new(contact)
    policy = case
    when contact.from_ungc?
      ContactPolicy::Ungc.new(contact)
    when contact.from_network?
      ContactPolicy::LocalNetwork.new(contact)
    when contact.from_organization?
      ContactPolicy::Organization.new(contact)
    else
      ContactPolicy::Default.new(contact)
    end
    Wrapper.new(contact, policy)
  end

  class Wrapper < SimpleDelegator

    def initialize(current_contact, policy)
      @current_contact = current_contact
      @policy = policy
      super(policy)
    end

    def can_destroy?(contact)
      if @current_contact == contact
        false # can't destroy yourself
      else
        @policy.can_destroy?(contact)
      end
    end

  end

end
