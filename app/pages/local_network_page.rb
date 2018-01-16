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
      image: 'https://d306pr3pise04h.cloudfront.net/uploads/b6/b6abac3ed0d54d4ac44ad1445dc62f8546ad7f3b---globe-map.jpg',
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
    "Read about the mission and vision of a specific Global Compact Local Network and learn what business sectors are represented by its participants."
  end

  def meta_keywords
  end

  def sidebar_widgets
    OpenStruct.new({
      calls_to_action: [
        {
          label: 'Share your Story',
          url: '/take-action/action/share-story'
        }
      ]
    }.merge(public_contacts))
  end

  def participants
    OpenStruct.new({
      total: local_network.participants.count,
      list: participants_by_sector
      })
  end

  def value_proposition_paths
    [2011].map do |year|
      filename = "/docs/networks_around_world_doc/communication/network_reports/#{year}/#{local_network.country_code}_VP.pdf"
      if FileTest.exists?("public/#{filename}")
        filename
      end
    end.compact
  end

  private

    def public_contacts
      executive_director = local_network.contacts.for_roles(Role.network_executive_director).first
      contact = local_network.contacts.network_contacts.order(:last_name, :first_name, :id).first

      executive_director = nil if executive_director&.id == contact&.id

      if executive_director && contact.nil?
        contact = executive_director
        executive_director = nil
      end

      executive_director_data = {
          name: executive_director.full_name_with_title,
          title: executive_director.job_title,
      } if executive_director

      {
          executive_director: executive_director_data,
          contact: as_sidebar_contact(contact)
      }
    end

  def as_sidebar_contact(contact)
    {
        name: contact.full_name_with_title,
        title: contact.job_title,
        email: contact.email,
        phone: contact.phone
    } unless contact.nil?
  end

    def participants_by_sector
      sectors = Sector
        .applicable
        .joins(organizations: :country)
        .where(countries: { local_network_id: local_network.id })
        .merge(Organization.visible_in_local_network)
        .group(:id, :parent_id, :name)
        .select(:id, :parent_id, :name, 'count(*) as participants_count')
        .reorder('participants_count desc')
        .limit(5)

      sectors.map do |sector|
        SectorSummary.new(sector, local_network.countries.map(&:id), sector.participants_count)
      end
    end

    SectorSummary = Struct.new(:sector, :country_ids, :participants_count) do

      def search_params
        params = {countries: country_ids}

        if sector.parent_id.present?
          params[:sectors] = [sector.id]
        else
          params[:sector_groups] = [sector.id]
        end

        params
      end

      def id
        sector.id
      end

      def name
        sector.name
      end

    end

    def local_network
      __getobj__
    end
end
