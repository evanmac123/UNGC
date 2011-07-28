module Importers
  module LocalNetworks
    class StructureGovernanceImporter < ExcelImporter
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
            puts "No country found: region = #{region.inspect}, name = #{country_name.inspect}"
            nil
          end
        else
          nil
        end
      end

      def update_model(model, row)
        model.sg_global_compact_launch_date = get_date(row, "Date Of Launch Of Global Compact In Country")
        model.sg_local_network_launch_date  = get_date(row, "Date Of Local Network Launch")
      end
    end
  end
end

