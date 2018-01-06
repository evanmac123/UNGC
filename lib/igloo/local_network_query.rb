module Igloo
  class LocalNetworkQuery

    def include?(contact)
      contacts.include?(contact)
    end

    def recent(cutoff = nil)
      contacts.
        includes(:country)
        .joins(:country)
        .where("contacts.updated_at >= :cutoff OR local_networks.updated_at >= :cutoff OR countries.updated_at > :cutoff", cutoff: cutoff)
    end

    def contacts
      # Contacts with usernames that are from active Local networks
      Contact.with_login.
        joins(:local_network).
        merge(LocalNetwork.active_networks)
    end

  end
end
