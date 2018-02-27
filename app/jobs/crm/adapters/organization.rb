# frozen_string_literal: true

module Crm
  module Adapters
    class Organization < Crm::Adapters::Base

      def build_crm_payload

        column('UNGC_ID__c', :id)
        column('AccountNumber', :id) { |organization| organization.id.to_s }

        column('Name', :name)
        column('Type', :organization_type_id) { |organization| organization.organization_type.name }
        column('Active_c__c', :active) { |organization| model.active.nil? ? false : model.active }
        column('State__c', :state) { |organization| I18n.t(organization.state) }
        column('Join_Date__c', :joined_on)
        column('JoinYear__c', :joined_on) { |organization| organization.joined_on&.year }
        column('Website', :url)
        column('TickerSymbol', :stock_symbol) { |organization| organization.stock_symbol&.truncate(20, omission: "") }
        column('Country__c', :country_id) { |organization| organization.country_name }
        column('Region__c', :country_id) { |organization| organization.region_name }

        column('Industry', :sector_id) { |organization| organization.sector_name }
        column('Sector__c', :sector_id) { |organization| organization.non_business? ? "Non-business" : "Business" }

        column('NumberOfEmployees', :employees) { |organization| organization.employees > 99999999 ? 99999999 : model.employees }
        column('Participant__c', :participant) { |organization| organization.participant == true }
        column('Reason_for_no_pledge_at_joining__c', :no_pledge_reason_value)
        column('Pledge_at_Joining__c', :pledge_amount)
        column('FT500__c', :is_ft_500) { |organization| organization.is_ft_500 == true }
        column('COP_Status__c', :cop_state)
        column('COP_Due_On__c', :cop_due_on)

        column('Delisted_ON__c', :delisted_on)
        column('Rejoined_On__c', :rejoined_on)

        column('ISIN__c', :isin)
        column('Desired_Contribution_Invoice_Date__c', :invoice_date)
        column('Participant_Tier_at_Joining__c', :level_of_participation) do |organization|
          case organization.level_of_participation
            when nil then nil
            when "signatory_level" then "Signatory"
            when "participant_level" then "Participant"
            else
              raise "Unexpected level of participation value: #{organization.level_of_participation}"
          end
        end

        column('Ownership', :listing_status_id) { |organization| organization.listing_status_name }
        column('OwnerId', :participant_manager) do |organization|
          organization.participant_manager&.crm_owner&.crm_id || Crm::Owner::SALESFORCE_OWNER_ID
        end

        column('Removal_Reason__c', :removal_reason) { |organization| organization.removal_reason&.description}

        column('Revenue__c', :revenue) { |organization| organization.revenue_range}
        column('AnnualRevenue', nil, true) do |organization|
          case
            when organization.precise_revenue.present?
              organization.precise_revenue.dollars
            when !organization.sme? && !organization.company?
              0
            else
              organization.bracketed_revenue_amount&.dollars || ''
          end
        end

        column('Revenue_is_Calculated__c', nil, true) { |organization| organization.revenue.present? && organization.precise_revenue.nil? }
        column('Last_COP_Date__c', nil, true) { |organization| organization.last_approved_cop&.published_on }
        column('Last_COP_Differentiation__c', nil, true) { |organization| organization.last_approved_cop&.differentiation }

        if relation_changed?(:contacts)
          ceo = model.contacts.ceos.first
          column('BillingStreet', :contacts, true) { ceo&.full_address }
          column('BillingCity', :contacts, true) { ceo&.city }
          column('BillingState', :contacts, true) { ceo&.state }
          column('BillingPostalCode', :contacts, true) { ceo&.postal_code&.truncate(20) }
          column('BillingCountry', :contacts, true) { ceo&.country&.name }
        end

        if relation_changed?(:signings)
          signings = model.signings.joins(:initiative).pluck('initiatives.name')

          column('Anti_corruption__c', :signings, true) { signed?(signings, :anti_corruption)}
          column('Board__c', :signings, true) { signed?(signings, :board_members)}
          column('B4P__c', :signings, true) { signed?(signings, :business4peace)}
          column('C4C__c', :signings, true) { signed?(signings, :climate)}
          column('CEO_Water_Mandate__c', :signings, true) do
            signed?(signings, :water_mandate) || signed?(signings, :water_mandate_non_endorsing)
          end

          column('LEAD__c', :signings, true) { signed?(signings, :lead)}
          column('GC100__c', :signings, true) { signed?(signings, :gc100)}
          column('Human_Rights_WG__c', :signings, true) { signed?(signings, :human_rights_wg)}
          column('Social_Enterprise__c', :signings, true) { signed?(signings, :human_rights_wg)}
          column('Supply_Chain_AG__c', :signings, true) { signed?(signings, :supply_chain)}
          column('WEPs__c', :signings, true) { signed?(signings, :weps)}
        end

      end

      private

      def signed?(signings, initiative_name)
        signings.include?(Initiative::FILTER_TYPES[initiative_name])
      end
    end
  end
end
