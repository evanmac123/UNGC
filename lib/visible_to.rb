module VisibleTo
  # XXX turn this into an extend and remove the class_eval
  def self.included(klass)
    klass.class_eval do
      # scopes the model depending on user_type
      # contacts that belong to an organization should only see models that share that organization
      # contacts from a local network should see all the models in the same country as their network
      # contacts from UNGC should see every model
      # no model should be seen otherwise
      scope :visible_to, lambda { |user|
        case user.user_type
        when Contact::TYPE_ORGANIZATION
          where('organization_id=?', user.organization_id)
        when Contact::TYPE_NETWORK || Contact::TYPE_NETWORK_GUEST
          includes(:organization).where("organizations.country_id in (?)", user.local_network.country_ids)
        when Contact::TYPE_UNGC
          {}
        else
          # should return no organizations.
          # TODO improve this when we port to rails 4
          where('1=2')
        end
      }
    end
  end
end
