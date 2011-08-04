module Importers
  module LocalNetworks
    class Base < ExcelImporter
      def get_local_network(row)
        name = get_value(row, "Country Name")

        if name.blank?
          warn "No local network name found on row \##{row.idx}"
          return nil
        end

        local_network = LocalNetwork.find_by_name(name)

        if local_network.nil?
          warn "Local network not found (#{name.inspect})"
          return nil
        end

        if block_given?
          yield(local_network)
        else
          local_network
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

      def get_date(row, column_name, order=:little)
        value = get_value(row, column_name)
        return nil if value.nil?

        value = "01/01/#{value}" if value =~ %r{^\d{4}$}

        if value =~ %r{^(\d{1,2})/(\d{1,2})/(\d{4})$}
          format = {:little => "%d/%m/%Y", :middle => "%m/%d/%Y"}.fetch(order)
          Date.strptime(value, format)
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

