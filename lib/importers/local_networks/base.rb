module Importers
  module LocalNetworks
    class Base < ExcelImporter
      def get_local_network(row)
        get_value(row, "Country Name") do |name|
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
      end

      def get_yesno(row, column_name)
        get_value(row, column_name) do |value|
          case value.downcase
          when "yes"
            true
          when "no"
            false
          else
            raise BadValue, "yes/no"
          end
        end
      end

      def get_integer(row, column_name)
        get_value(row, column_name) do |value|
          begin
            Integer(value)
          rescue ArgumentError
            raise BadValue, "integer"
          end
        end
      end

      def get_date(row, column_name, order=:little)
        get_value(row, column_name) do |value|
          value = "01/01/#{value}" if value =~ %r{^\d{4}$}

          if value =~ %r{^(\d{1,2})/(\d{1,2})/(\d{4})$}
            format = {:little => "%d/%m/%Y", :middle => "%m/%d/%Y"}.fetch(order)

            begin
              Date.strptime(value, format)
            rescue ArgumentError
              raise BadValue, "date"
            end
          else
            raise BadValue, "date"
          end
        end
      end
    
      def get_boolean_from_csv(row, column_name, lookup_term)
        get_value(row, column_name) do |value|
          values = value.split(',') 
          values.include?(lookup_term)
        end
      end
    
    end
  end
end

