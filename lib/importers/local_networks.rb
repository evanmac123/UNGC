require "importers/excel_importer"

Dir[RAILS_ROOT + "/lib/importers/local_networks/**/*"].each do |path|
  require path
end

module Importers
  module LocalNetworks
    class Runner
      def initialize(path, specific_class_name=nil)
        @path = path
        @specific_class_name = specific_class_name
      end

      def run
        importer_class_names.each do |name|
          klass = "Importers::LocalNetworks::#{name}".constantize
          klass.new(@path).run
        end
      end

      def importer_class_names
        if @specific_class_name
          [@specific_class_name]
        else
          LocalNetworks.constants.map(&:to_s).grep(/Importer$/)
        end
      end
    end
  end
end

