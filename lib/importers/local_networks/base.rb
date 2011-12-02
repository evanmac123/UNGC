module Importers
  module LocalNetworks
    class Base < ExcelImporter
      attr_accessor :file_directory

      def initialize(path)
        @path = path
        @corrections = YAML.load_file(File.expand_path("../corrections.yml", __FILE__))
      end

      def get_local_network(row)
        get_value(row, "Country Name") do |name|
          if name.blank?
            warn "No local network name found on row \##{row.idx}"
            return nil
          end

          name = @corrections["network_names"].fetch(name, name)

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
          case value.split.first.downcase
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

      FILENAME_REGEX = /
        [^.]+ # one or more non-dot chars
        \.    # dot
        [^ ]+ # one or more non-space chars
      /x

      def get_files(row, column_name)
        if @file_directory.nil?
          unless @file_directory_nil_already_warned
            warn "You need to specify a file directory with -d or --file-directory in order to import files."
            @file_directory_nil_already_warned = true
          end

          return []
        end

        [].tap do |filenames|
          get_value(row, column_name) do |value|
            matches = value.scan(FILENAME_REGEX).map(&:strip)

            matches.each do |filename|
              path = File.join(@file_directory, filename)

              if File.exist?(path)
                notice "File imported: #{path.inspect}"
                filenames << UploadedFile.new(:attachment => File.new(path))
              else
                warn "File not found: #{path.inspect}"
              end
            end
          end
        end
      end
    end
  end
end

