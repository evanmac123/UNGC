module Importers
  module LocalNetworks
    class NetworkManagementImporter < ExcelImporter
      def worksheet_name
        "NetworkManagementAndFastFact"
      end

      def init_model(row)
        name = get_value(row, "GCLN Name")

        if name.blank?
          warn "No local network name found on row \##{row.idx}"
          return nil
        end

        local_network = LocalNetwork.find_by_name(name)

        if local_network.nil?
          warn "Local network not found (#{name.inspect})"
          return nil
        end

        local_network
      end

      def update_model(model, row)
        model.sg_global_compact_launch_date = get_date(row, "Date Of Launch Of Global Compact In Country")
        model.sg_local_network_launch_date  = get_date(row, "Date Of Local Network Launch")
      end

      def model_string(local_network)
        if local_network
          local_network.name
        else
          super
        end
      end

      def get_date(row, column_name)
        value = get_value(row, column_name)
        return nil if value.nil?

        if value =~ %r{^(\d{1,2})/(\d{1,2})/(\d{4})}
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

