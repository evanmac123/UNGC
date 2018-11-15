# frozen_string_literal: true

module Academy
  class ViewersReport < SimpleReport

    def records
      Contact.joins(:roles)
        .joins("left join organizations on organization_id = organizations.id")
        .joins("left join local_networks on local_network_id = local_networks.id")
        .where(roles: { id: Role.academy_viewer.id })
        .where("contacts.created_at >= ?", Academy::LAUNCH_DATE)
        .reorder(created_at: :desc)
    end

    def headers
      [
        "Contact ID",
        "Name",
        "Email",
        "Created at",
        "Organization Name",
        "Local Network Name",
      ]
    end

    def row(contact)
      [
        contact.id,
        contact.name,
        contact.email,
        contact.created_at,
        contact.organization&.name,
        contact.local_network&.name,
      ]
    end
  end
end
