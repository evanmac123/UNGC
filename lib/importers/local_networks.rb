require "importers/excel_importer"

Dir[RAILS_ROOT + "/lib/importers/local_networks/**/*"].each do |path|
  require path
end

module Importers
  module LocalNetworks
    class Runner
      def initialize(*args)
        @path, @file_directory, @class_name = *args
      end

      def run
        importer_class_names.each do |name|
          klass = "Importers::LocalNetworks::#{name}".constantize
          klass.new(@path, @file_directory).run
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

