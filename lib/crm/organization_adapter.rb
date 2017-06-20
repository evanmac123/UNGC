module Crm
  class OrganizationAdapter

    def to_crm_params(organization, fields = [])
      # TODO Only send fields that have changed. If fields is non-empty, it indicates
      # which fields need to be sent.
      ceo = organization.contacts.ceos.first
      signings = organization.signings.map(&:initiative_id)
      {
        "UNGC_ID__c" => organization.id, # Number(18, 0)
        "AccountNumber" => organization.id.to_s, # AccountNumber must be a string Name
        "Sector__c" => convert_sector(organization), # Picklist
        "Join_Date__c" => organization.joined_on, # Date
        "JoinYear__c" => organization.joined_on.try!(:year), # Number(4, 0)
        "Type" => organization.organization_type.name, # Picklist
        "Country__c" => organization.country_name, # Picklist
        "Name" => organization.name, # Name
        "Industry" => organization.sector_name, # Picklist
        "NumberOfEmployees" => organization.employees, # Number(8, 0)
        "Pledge_at_Joining__c" => organization.pledge_amount, # Currency(10, 2)
        "Reason_for_no_pledge_at_joining__c" => organization.no_pledge_reason_value, # Text(250)
        "Revenue__c" => organization.revenue_range, # Picklist
        "AnnualRevenue" => revenue(organization), # Number(18, 0)
        "FT500__c" => organization.is_ft_500.present?, # Checkbox
        "Region__c" => organization.region_name, # Picklist
        "COP_Status__c" => organization.cop_state, # Picklist
        "COP_Due_On__c" => organization.cop_due_on, # Date
        "Last_COP_Date__c" => organization.last_approved_cop.try!(:published_on), # Date
        "Last_COP_Differentiation__c" => organization.last_approved_cop.try!(:differentiation), # Text(30)
        "Active_c__c" => active?(organization), # Checkbox
        "Ownership" => organization.listing_status_name, # Picklist
        "Delisted_ON__c" => organization.delisted_on, # Date
        "Rejoined_On__c" => organization.rejoined_on, # Date
        "Local_Network__c" => organization.local_network.present?, # Checkbox
        "State__c" => I18n.t(organization.state), # Picklist
        "OwnerId" => Crm::Owner.owner_id(organization.participant_manager_id), # Lookup(User)
        "Removal_Reason__c" => organization.removal_reason.try!(:description), # Picklist
        "ISIN__c" => organization.isin, # Text(40)
        # Billing Address
        "BillingStreet" => ceo.try!(:full_address),
        "BillingCity" => ceo.try!(:city),
        "BillingState" => ceo.try!(:state),
        "BillingPostalCode" => ceo.try!(:postal_code).try!(:truncate, 20),
        "BillingCountry" => ceo.try!(:country).try!(:name),

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
        "TickerSymbol" => organization.stock_symbol.try!(:truncate, 20, omission: ""), # Content(20)
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
      if organization.precise_revenue.present?
        organization.precise_revenue.dollars.to_i
      else
        organization.revenue_upper_value
      end
    end

  end
end
