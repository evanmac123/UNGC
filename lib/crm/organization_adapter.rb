module Crm
  class OrganizationAdapter < AdapterBase

    def to_crm_params(organization, fields = [])
      # TODO Only send fields that have changed. If fields is non-empty, it indicates
      # which fields need to be sent.
      ceo = organization.contacts.ceos.first
      signings = organization.signings.joins(:initiative).pluck('initiatives.name')
      {
        "UNGC_ID__c" => organization.id, # Number(18, 0)
        "AccountNumber" => organization.id.to_s, # AccountNumber must be a string Name
        "Sector__c" => convert_sector(organization), # Picklist
        "Join_Date__c" => organization.joined_on, # Date
        "JoinYear__c" => organization.joined_on&.year, # Number(4, 0)
        "Type" => organization.organization_type.name, # Picklist
        "Country__c" => organization.country_name, # Picklist
        "Name" => organization.name, # Name
        "Industry" => organization.sector_name, # Picklist
        "NumberOfEmployees" => employees(organization), # Number(8, 0)
        "Pledge_at_Joining__c" => organization.pledge_amount, # Currency(10, 2)
        "Reason_for_no_pledge_at_joining__c" => organization.no_pledge_reason_value, # Text(250)
        "Revenue__c" => organization.revenue_range, # Picklist
        "AnnualRevenue" => revenue(organization), # Number(18, 0)
        "Revenue_is_Calculated__c" => organization.precise_revenue.nil? && organization.revenue.present?, # Checkbox
        "FT500__c" => organization.is_ft_500.present?, # Checkbox
        "Region__c" => organization.region_name, # Picklist
        "COP_Status__c" => organization.cop_state, # Picklist
        "COP_Due_On__c" => organization.cop_due_on, # Date
        "Last_COP_Date__c" => organization.last_approved_cop&.published_on, # Date
        "Last_COP_Differentiation__c" => organization.last_approved_cop&.differentiation, # Text(30)
        "Active_c__c" => active?(organization), # Checkbox
        "Ownership" => organization.listing_status_name, # Picklist
        "Delisted_ON__c" => organization.delisted_on, # Date
        "Rejoined_On__c" => organization.rejoined_on, # Date
        "Local_Network__c" => organization.local_network.present?, # Checkbox
        "State__c" => I18n.t(organization.state), # Picklist
        "OwnerId" => organization.participant_manager&.crm_owner&.crm_id || Crm::Owner::DEFAULT_OWNER_ID,
        "Removal_Reason__c" => organization.removal_reason&.description, # Picklist
        "ISIN__c" => organization.isin, # Text(40)
        # Billing Address
        "BillingStreet" => ceo&.full_address,
        "BillingCity" => ceo&.city,
        "BillingState" => ceo&.state,
        "BillingPostalCode" => ceo&.postal_code&.truncate(20),
        "BillingCountry" => ceo&.country&.name,

        "Anti_corruption__c" => signed?(signings, :anti_corruption), # Checkbox
        "Board__c" => signed?(signings, :board_members), # Checkbox
        "B4P__c" => signed?(signings, :business4peace), # Checkbox
        "C4C__c" => signed?(signings, :climate), # Checkbox
        "CEO_Water_Mandate__c" => signed?(signings, :water_mandate) ||
                                  signed?(signings, :water_mandate_non_endorsing), # Checkbox
        "LEAD__c" => signed?(signings, :lead), # Checkbox
        "GC100__c" => signed?(signings, :gc100), # Checkbox
        "Human_Rights_WG__c" => signed?(signings, :human_rights_wg), # Checkbox
        "Social_Enterprise__c" => signed?(signings, :social_enterprise), # Checkbox
        "Supply_Chain_AG__c" => signed?(signings, :supply_chain), # Checkbox
        "WEPs__c" => signed?(signings, :weps), # Checkbox
        "Participant_Tier__c" => "Unselected", # Picklist
        "Participant__c" => organization.participant == true, # Checkbox
        "TickerSymbol" => organization.stock_symbol&.truncate(20, omission: ""), # Content(20)
        "Participant_Tier_at_Joining__c" => participant_tier(organization), # Picklist
        "Desired_Contribution_Invoice_Date__c" => organization.invoice_date,
      }.transform_values do |value|
        Crm::Salesforce.coerce(value)
      end
    end

    private

    def signed?(signings, initiative_name)
      signings.include?(Initiative::FILTER_TYPES[initiative_name])
    end

    def convert_sector(organization)
      if organization.non_business?
        "Non-business"
      else
        "Business"
      end
    end

    def active?(organization)
      if organization.active.nil?
        false
      else
        organization.active
      end
    end

    def revenue(organization)
      case
      when organization.precise_revenue.present?
        organization.precise_revenue.dollars
      when !organization.sme? && !organization.company?
        0
      else
        organization.bracketed_revenue_amount&.dollars || ""
      end
    end

    def participant_tier(organization)
      case organization.level_of_participation
      when nil then nil
      when "signatory_level" then "Signatory"
      when "participant_level" then "Participant"
      else
        raise "Unexpected level of participation value: #{organization.level_of_participation}"
      end
    end

    def employees(organization)
      if organization.employees > 99999999
        99999999
      else
        organization.employees
      end
    end

  end
end
