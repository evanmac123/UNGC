module VisibleTo
  def self.included(klass)
    klass.class_eval do
      named_scope :visible_to, lambda { |user|
        if user.user_type == Contact::TYPE_ORGANIZATION
          { :conditions => ['organization_id=?', user.organization_id] }
        elsif user.user_type == Contact::TYPE_NETWORK
          { :conditions => ["organizations.country_id in (?)", user.local_network.country_ids],
            :include    => :organization }
        else
          {}
        end
      }
    end
  end
end
