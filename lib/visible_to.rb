module VisibleTo
  def self.included(klass)
    klass.class_eval do
      scope :visible_to, lambda { |user|
        if user.user_type == Contact::TYPE_ORGANIZATION
          where('organization_id=?', user.organization_id)
        elsif user.user_type == Contact::TYPE_NETWORK || user.user_type == Contact::TYPE_NETWORK_GUEST
          { :conditions => ["organizations.country_id in (?)", user.local_network.country_ids],
            :include    => :organization }
        elsif user.user_type == Contact::TYPE_UNGC
          {}
        else
          # TODO improve this when we port to rails 4
          where('1=2')
        end
      }
    end
  end
end
