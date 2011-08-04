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
        model.sg_global_compact_launch_date = get_date(row, "Date Of Launch Of Global Compact In Country")
        model.sg_local_network_launch_date  = get_date(row, "Date Of Local Network Launch")

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

        model.fees_participant               = get_yesno(row, "Participant Fees")
        model.fees_amount_company            = get_integer(row, "Company Fee")
        model.fees_amount_sme                = get_integer(row, "SME Fee")
        model.fees_amount_other_organization = get_integer(row, "Other Organization Fee")
        model.fees_amount_participant        = get_integer(row, "Participant  Fees")
        model.fees_amount_voluntary_private  = get_integer(row, "Private Voluntary Contribution")
        model.fees_amount_voluntary_public   = get_integer(row, "Public Voluntary Contribution")
      end

      def model_string(local_network)
        if local_network
          local_network.name
        else
          super
        end
      end

      def get_yesno(row, column_name)
        value = get_value(row, column_name)
        return nil if value.nil?

        case value.downcase
        when "yes"
          true
        when "no"
          false
        else
          warn_of_bad_value(row, column_name, "yes/no")
          nil
        end
      end

      def get_integer(row, column_name)
        value = get_value(row, column_name)
        return nil if value.nil?

        begin
          Integer(value)
        rescue ArgumentError
          warn_of_bad_value(row, column_name, "integer")
          nil
        end
      end

      def get_date(row, column_name)
        value = get_value(row, column_name)
        return nil if value.nil?

        if value =~ %r{^(\d{4})}
          value = "01/01/#{value}"
          Date.strptime(value, "%d/%m/%Y")
        elsif value =~ %r{^(\d{1,2})/(\d{1,2})/(\d{4})}
          Date.strptime(value, "%d/%m/%Y")
        else
          warn_of_bad_value(row, column_name, "date")
          nil
        end
      end

      def warn_of_bad_value(row, column_name, type)
        warn "Bad #{type} value on row \##{row.idx}, column name #{column_name.inspect}: #{get_value(row, column_name).inspect}"
      end

    end
  end
end

