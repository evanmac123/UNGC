# frozen_string_literal: true

module Saml
  class User

    def initialize(contact)
      @contact = contact
    end

    def asserted_attributes
      {
        Id:                  { getter: :id },
        Email:               { getter: :email },
        FName:               { getter: :first_name },
        LName:               { getter: :last_name },
        Username:            { getter: :username },
        CompanyName:         { getter: :company_name },
        Country:             { getter: :country },
        ParticipantCountry:  { getter: :participant_country },
        LocalNetworkCountry: { getter: :local_network_country },
        Sector:              { getter: :sector },
        Region:              { getter: :region },
        OrganizationType:    { getter: :organization_type },
        Employees:           { getter: :employees },
        JoinedOn:            { getter: :joined_on },
        FT500:               { getter: :ft500 },
        JobTitle:            { getter: :job_title },
      }
    end

    def id
      @contact.id
    end

    def email
      @contact.email
    end

    def first_name
      @contact.first_name
    end

    def last_name
      @contact.last_name
    end

    def username
      @contact.username
    end

    def company_name
      case
        when @contact.from_network?
          @contact.local_network.name
        else
          @contact.organization&.name
      end
    end

    def country
      @contact.country&.name
    end

    def participant_country
      @contact.organization&.country&.name
    end

    def local_network_country
      @contact.local_network&.country&.name
    end

    def sector
      if @contact.from_organization?
        @contact.organization.sector&.name
      end
    end

    def region
      case
        when @contact.from_ungc? || @contact.from_organization?
          @contact.organization.country&.region
        when @contact.from_network?
          @contact.local_network.country&.region
        else
          @contact.country&.region
      end
    end

    def organization_type
      if @contact.from_organization?
        @contact.organization.organization_type&.name
      end
    end

    def employees
      if @contact.from_organization?
        @contact.organization.employees
      end
    end

    def joined_on
      if @contact.from_organization?
        @contact.organization.joined_on
      end
    end

    def ft500
      if @contact.from_organization?
        @contact.organization.is_ft_500 ? "yes" : "no"
      end
    end

    def job_title
      @contact.job_title
    end

  end

end
