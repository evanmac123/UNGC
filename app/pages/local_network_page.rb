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
          label: 'Share your Story',
          url: '/take-action/action/share-story'
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
      return nil unless contact
      {
        name: contact.full_name_with_title,
        title: contact.job_title,
        email: contact.email,
        phone: contact.phone
      }
    end

    def network_representative
      contact = local_network.contacts.joins(:roles).where("roles.name = ?", Role::FILTERS[:network_representative]).first
      return nil unless contact
      contact.try(:full_name_with_title)
    end

    def participants_by_sector
      sectors = local_network
        .participants
        .joins(:sector)
        .group('sectors.id')
        .select(
          'sectors.id',
          'sectors.parent_id',
          'sectors.name',
          'count(sectors.id) as participants_count')
        .order('participants_count desc')
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
        if sector.name == Sector::NOT_APPLICABLE
          'Non Business'
        else
          sector.name
        end
      end

    end

    def local_network
      __getobj__
    end
end

