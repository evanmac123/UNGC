module Igloo
  class StaffQuery

    def include?(contact)
      contacts.include?(contact)
    end

    def recent(cutoff)
      contacts.where("contacts.updated_at > ?", cutoff)
    end

    private

    def contacts
      Contact.ungc_staff
    end
  end
end
