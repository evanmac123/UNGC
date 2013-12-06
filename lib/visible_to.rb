module VisibleTo
  def self.included(klass)
    klass.class_eval do
      scope :visible_to, lambda { |user|
        if user.user_type == Contact::TYPE_ORGANIZATION
          where('organization_id=?', user.organization_id)
        elsif user.user_type == Contact::TYPE_NETWORK
          { :conditions => ["organizations.country_id in (?)", user.local_network.country_ids],
            :include    => :organization }
        elsif user.user_type == Contact::TYPE_UNGC && user.is?(Role.participant_manager)
          # { :conditions => ['organizations.participant_manager_id=?', user.id],
          #   :include    => :organization }
        else
          {}
        end
      }
    end
  end
end