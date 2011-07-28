require "importers/excel_importer"
require "importers/local_networks/structure_governance_importer"

module Importers
  module LocalNetworks
    class MainImporter
      def initialize(path)
        @path = path
      end

      def run
        importer_classes.each do |klass|
          klass.new(@path).run
        end
      end

      def importer_classes
        [StructureGovernanceImporter]
      end
    end
  end
end

