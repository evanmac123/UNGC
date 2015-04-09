 class ParticipantSearch::Result < SimpleDelegator

    def type
      organization.organization_type.name
    end

    def sector
      organization.sector.name
    end

    def country
      organization.country.name
    end

    def company_size
      organization.employees
    end

    private

    def organization
      __getobj__
    end

  end
