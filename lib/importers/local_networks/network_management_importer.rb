module Importers
  module LocalNetworks
    class NetworkManagementImporter < Base
      def worksheet_name
        "NetworkManagementAndFastFact"
      end

      def init_model(row)
        get_local_network(row)
      end

      def update_model(model, row)
        model.sg_global_compact_launch_date     = get_date(row, "Date Of Launch Of Global Compact In Country")
        model.sg_local_network_launch_date      = get_date(row, "Date Of Local Network Launch")
        model.sg_annual_meeting_appointments    = get_yesno(row, "Does Annual General Meeting Appoint/Elect Steering Committee/Board?")
        model.sg_established_as_a_legal_entity  = get_yesno(row, "Has the GCLN been established as a legal entity?")
        model.sg_selected_appointees_steering_committee = get_yesno(row, "Does Annual General Meeting Appoint/Elect Steering Committee/Board?")
        model.sg_selected_appointees_contact_point      = get_yesno(row, "Does Annual General Meeting Or Steering Committee Appoint GCLN Focal Point")
        
        model.membership_subsidiaries           = get_yesno(row, "Subsidiaries Of Multi-National Companies Participate In Local Network Activities")
        model.membership_companies              = get_integer(row, "Companies > 250 Employees")
        model.membership_sme                    = get_integer(row, "Small and Medium sized Enterprise (10 - 249) employees")
        model.membership_micro_enterprise       = get_integer(row, "Micro-Companies (< 10 employees)")
        model.membership_business_organizations = get_integer(row, "Business Organizations")
        model.membership_csr_organizations      = get_integer(row, "CSR Organizations")
        model.membership_labour_organizations   = get_integer(row, "Labour Organizations")
        model.membership_civil_societies        = get_integer(row, "Civil Society Organizations/NGOs")
        model.membership_academic_institutions  = get_integer(row, "Academic Institutions")
        model.membership_government             = get_integer(row, "Government Entities")
        model.membership_other                  = get_integer(row, "Other Stakeholders")

        model.fees_participant                  = get_yesno(row, "Participant Fees")
        model.fees_amount_company               = get_integer(row, "Company Fee")
        model.fees_amount_sme                   = get_integer(row, "SME Fee")
        model.fees_amount_other_organization    = get_integer(row, "Other Organization Fee")
        model.fees_amount_participant           = get_integer(row, "Participant  Fees")
        model.fees_amount_voluntary_private     = get_integer(row, "Private Voluntary Contribution")
        model.fees_amount_voluntary_public      = get_integer(row, "Public Voluntary Contribution")
        
        model.stakeholder_company               = get_boolean_from_csv(row, "Stakeholder Groups Involved In Governance:", "Business")
        model.stakeholder_sme                   = get_boolean_from_csv(row, "Stakeholder Groups Involved In Governance:", "SMEs")
        model.stakeholder_business_association  = get_boolean_from_csv(row, "Stakeholder Groups Involved In Governance:", "Business Associations")
        model.stakeholder_labour                = get_boolean_from_csv(row, "Stakeholder Groups Involved In Governance:", "Labour")
        model.stakeholder_un_agency             = get_boolean_from_csv(row, "Stakeholder Groups Involved In Governance:", "UN Agency")
        model.stakeholder_ngo                   = get_boolean_from_csv(row, "Stakeholder Groups Involved In Governance:", "NGOs")
        model.stakeholder_foundation            = get_boolean_from_csv(row, "Stakeholder Groups Involved In Governance:", "Foundations")
        model.stakeholder_academic              = get_boolean_from_csv(row, "Stakeholder Groups Involved In Governance:", "Academies")
        model.stakeholder_government            = get_boolean_from_csv(row, "Stakeholder Groups Involved In Governance:", "Government Entity")
      end

      def model_string(local_network)
        if local_network
          local_network.name
        else
          super
        end
      end
    end
  end
end