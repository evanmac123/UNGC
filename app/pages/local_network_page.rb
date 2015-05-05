class LocalNetworkPage < SimpleDelegator

  def regions_nav
    return Components::RegionsNav.new
  end

  def hero
    {
      title: {
        title1: 'Act Globally',
        title2: 'Engage Locally'
      },
      size: 'small',
      show_regions_nav: true
    }
  end

  def description
    local_network.description
  end

  def meta_title
    local_network.name
  end

  def meta_description
  end

  def meta_keywords
  end

  def sidebar_widgets
    OpenStruct.new({
      contact: network_contact,
      network_representative: network_representative,
      calls_to_action: [
        {
          label: 'Share your Success',
          url: '/take_action/action/share-success'
        }
      ]
    })
  end

  def participants
    OpenStruct.new({
      total: local_network.participants.count,
      list: participants_by_sector
      })
  end

  private

    def network_contact
      contact = local_network.contacts.joins(:roles).where("roles.name = ?", Role::FILTERS[:network_focal_point]).first
      {
        name: contact.full_name_with_title,
        title: contact.job_title,
        email: contact.email,
        phone: contact.phone
      }
    end

    def network_representative
      contact = local_network.contacts.joins(:roles).where("roles.name = ?", Role::FILTERS[:network_representative]).first
      contact.try(:full_name_with_title)
    end


    def participants_by_sector
      hash = local_network.participants.joins(:sector).group('sectors.name', 'sectors.id').count
      sorted = hash.sort { |a,b| b[1] <=> a[1]}
      sorted.map do |k,v|
        {
          sector: k[0],
          id: k[1],
          count: v
        }
      end.take(5)
    end

    def local_network
      __getobj__
    end
end

