module VisibleTo
  def self.included(klass)
    klass.class_eval do
      scope :visible_to, lambda { |user|
        if user.user_type == Contact::TYPE_ORGANIZATION
          where('organization_id=?', user.organization_id)
        elsif user.user_type == Contact::TYPE_NETWORK
          where("organizations.country_id IN (?)", user.local_network.country_ids).includes(:organization)
        else
          {}
        end
      }
    end
  end
end
