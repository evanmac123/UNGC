module Importers
  module LocalNetworks
    class MembershipImporter < ExcelImporter
      def worksheet_name
        "NetworkManagementAndFastFact"
      end

      def init_model(row)
        nil
      end

      def update_model(model, row)
        puts "Hello from MembershipImporter"
      end
    end
  end
end


