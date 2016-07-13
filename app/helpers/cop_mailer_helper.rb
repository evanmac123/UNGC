module CopMailerHelper

  def link_to_local_network(org)
    if org.local_network_country_code
      continent = Region.find_by(name: org.country.region).param

      if org.country.local_network
        networks_show_url(continent, org.country.local_network.name.downcase)
      else
        raise ActiveRecord::RecordNotFound
      end
    else
      URI.join(root_url, '/engage-locally').to_s
    end
  end

  def local_network_name(org)
    if org.local_network_name.present?
      "Your Local Network in #{org.local_network_name}"
    else
      'Find your Local Network'
    end
  end

  def link_to_letter_of_commitment_if_available(org)
    if org.commitment_letter?
      link_to 'Letter of Commitment', 'http://unglobalcompact.org' + org.commitment_letter.url
    else
      "Letter of Commitment"
    end
  end

end
