module VisibleTo
  # XXX turn this into an extend and remove the class_eval
  def self.included(klass)
    klass.class_eval do
      # scopes the organization depending on the user_type
      # contacts that belong to an organization should only see their organization
      # contacts from a local network should see all the organizations in their network
      # contacts from UNGC should see every organization
      # no organizations should be seen otherwise,
      scope :visible_to, lambda { |user|
        if user.user_type == Contact::TYPE_ORGANIZATION
          where('organization_id=?', user.organization_id)
        elsif user.user_type == Contact::TYPE_NETWORK || user.user_type == Contact::TYPE_NETWORK_GUEST
          { :conditions => ["organizations.country_id in (?)", user.local_network.country_ids],
            :include    => :organization }
        elsif user.user_type == Contact::TYPE_UNGC
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
