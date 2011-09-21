require "importers/excel_importer"

Dir[RAILS_ROOT + "/lib/importers/local_networks/**/*"].each do |path|
  require path
end

module Importers
  module LocalNetworks
    class Runner
      def initialize(path, options)
        @path = path
        @file_directory = options[:file_directory]
        @class_name = options[:class_name]
        @log_file_name = options[:log_file_name]
      end

      def run
        importer_class_names.each do |name|
          klass = "Importers::LocalNetworks::#{name}".constantize
          importer = klass.new(@path)

          importer.file_directory = @file_directory                 if @file_directory
          importer.log_file       = File.open(@log_file_name, "w+") if @log_file_name

          importer.run
        end
      end

      def importer_class_names
        if @class_name
          [@class_name]
        else
          LocalNetworks.constants.map(&:to_s).grep(/Importer$/)
        end
      end
    end
  end
end

