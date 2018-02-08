# frozen_string_literal: true

module Crm
  module Adapters
    class Organization < Crm::Adapters::Base

      def to_crm_params(transform_action)
        ceo = model.contacts.ceos.first
        signings = model.signings.joins(:initiative).pluck('initiatives.name')
        {
            "UNGC_ID__c" => model.id, # Number(18, 0)
            "AccountNumber" => model.id.to_s, # AccountNumber must be a string Name
            "Sector__c" => convert_sector, # Picklist
            "Join_Date__c" => model.joined_on, # Date
            "JoinYear__c" => model.joined_on&.year, # Number(4, 0)
            "Type" => model.organization_type.name, # Picklist
            "Country__c" => model.country_name, # Picklist
            "Name" => model.name, # Name
            "Industry" => model.sector_name, # Picklist
            "NumberOfEmployees" => employees, # Number(8, 0)
            "Pledge_at_Joining__c" => model.pledge_amount, # Currency(10, 2)
            "Reason_for_no_pledge_at_joining__c" => model.no_pledge_reason_value, # Text(250)
            "Revenue__c" => model.revenue_range, # Picklist
            "AnnualRevenue" => revenue, # Number(18, 0)
            "Revenue_is_Calculated__c" => model.precise_revenue.nil? && model.revenue.present?, # Checkbox
            "FT500__c" => model.is_ft_500.present?, # Checkbox
            "Region__c" => model.region_name, # Picklist
            "COP_Status__c" => model.cop_state, # Picklist
            "COP_Due_On__c" => model.cop_due_on, # Date
            "Last_COP_Date__c" => model.last_approved_cop&.published_on, # Date
            "Last_COP_Differentiation__c" => model.last_approved_cop&.differentiation, # Text(30)
            "Active_c__c" => active?, # Checkbox
            "Ownership" => model.listing_status_name, # Picklist
            "Delisted_ON__c" => model.delisted_on, # Date
            "Rejoined_On__c" => model.rejoined_on, # Date
            "Local_Network__c" => model.local_network.present?, # Checkbox
            "State__c" => I18n.t(model.state), # Picklist
            "OwnerId" => model.participant_manager&.crm_owner&.crm_id || Crm::Owner::DEFAULT_OWNER_ID,
            "Removal_Reason__c" => model.removal_reason&.description, # Picklist
            "ISIN__c" => model.isin, # Text(40)
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
            "Participant__c" => model.participant == true, # Checkbox
            "TickerSymbol" => model.stock_symbol&.truncate(20, omission: ""), # Content(20)
            "Participant_Tier_at_Joining__c" => participant_tier, # Picklist
            "Desired_Contribution_Invoice_Date__c" => model.invoice_date,
        }
      end

      private

      def signed?(signings, initiative_name)
        signings.include?(Initiative::FILTER_TYPES[initiative_name])
      end

      def convert_sector
        if model.non_business?
          "Non-business"
        else
          "Business"
        end
      end

      def active?
        if model.active.nil?
          false
        else
          model.active
        end
      end

      def revenue
        case
          when model.precise_revenue.present?
            model.precise_revenue.dollars
          when !model.sme? && !model.company?
            0
          else
            model.bracketed_revenue_amount&.dollars || ""
        end
      end

      def participant_tier
        case model.level_of_participation
          when nil then nil
          when "signatory_level" then "Signatory"
          when "participant_level" then "Participant"
          else
            raise "Unexpected level of participation value: #{model.level_of_participation}"
        end
      end

      def employees
        if model.employees > 99999999
          99999999
        else
          model.employees
        end
      end

    end
  end
end
