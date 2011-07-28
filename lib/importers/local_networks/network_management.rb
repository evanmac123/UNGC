module Importers
  module LocalNetworks
    class NetworkManagement < ExcelImporter
      def worksheet_name
        "NetworkManagementAndFastFact"
      end

      def init_model(row)
        region = get_value(row, "Region Name")
        country_name = get_value(row, "Country Name")

        if region.present? and country_name.present?
          region = region[/\w+/].capitalize
          country = Country.find_by_region_and_name(region, country_name)

          if country
            country.local_network
          else
            warn "No country found: region = #{region.inspect}, name = #{country_name.inspect}"
            nil
          end
        else
          nil
        end
      end

      def get_date(row, column_name)
        value = get_value(row, column_name).strip

        if value == ""
          nil
        elsif value =~ %r{^(\d{1,2})/(\d{1,2})/(\d{4})}
          Date.strptime(value, "%d/%m/%Y")
        else
          warn "Bad date on row \##{row.idx}, column #{column_name.inspect}: #{value.inspect}"
          nil
        end
      end
    end

    class StructureGovernanceImporter < NetworkManagement
      def update_model(model, row)
        model.sg_global_compact_launch_date = get_date(row, "Date Of Launch Of Global Compact In Country")
        model.sg_local_network_launch_date  = get_date(row, "Date Of Local Network Launch")
      end
    end

    class MembershipImporter < NetworkManagement
      def update_model(model, row)
        # todo
      end
    end
  end
end

