module Academy
  class Viewer < ::Contact
    attr_accessor :country_name, :organization_name

    validates :organization, presence: true

    WHITELIST = [
      7553, # PwC
    ].freeze

    def can_login?
      true
    end

    def password_required?
      false
    end

    def should_sync_to_salesforce?
      false
    end

    def submit_pending_operation
      if country_id.blank? && country_name.present?
        self.country = Country.find_by(name: country_name)
      end

      if organization_id.blank? && organization_name.present?
        self.organization = Organization.find_by(name: organization_name)
      end

      existing_contact = Contact.find_by(
        email: email, organization_id: organization_id)

      if existing_contact
        self.id = existing_contact.id

        attrs = self.attributes
        self.reload
        assign_attributes(attrs)
      end

      if valid?
        if requires_approval?
          if new_record?
            RequestMembership.new(self).execute
          else
            RequestUsername.new(self).execute
          end
        else
          if new_record?
            CreateNewContact.new(self).execute
          else
            ClaimUsername.new(self).execute
          end
        end
      end
    end

    private

    def requires_approval?
      !WHITELIST.include?(organization_id)
    end

  end
end
