# frozen_string_literal: true

module Academy
  class ViewersReport < SimpleReport

    def records
      Contact.joins(:roles, :organization)
        .where(roles: { id: Role.academy_viewer.id })
        .where("contacts.created_at >= ?", Academy::LAUNCH_DATE)
        .reorder(created_at: :desc)
    end

    def headers
      [
        "Contact ID",
        "Name",
        "Created at",
        "Organization Name",
        "Local Network Name",
      ]
    end

    def row(contact)
      [
        contact.id,
        contact.name,
        contact.created_at,
        contact.organization&.name,
        contact.local_network&.name,
      ]
    end
  end
end
