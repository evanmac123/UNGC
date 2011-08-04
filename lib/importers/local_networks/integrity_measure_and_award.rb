module Importers
  module LocalNetworks
    class IntegrityMeasureAndAwardImporter < Base
      def worksheet_name
        "Integrity Measure And Award"
      end

      def init_model(row)
        get_local_network(row) do |local_network|
          date = get_date(row, "Award Date", :middle)
          date && local_network.awards.find_or_initialize_by_date(date)
        end
      end
      
      def update_model(model, row)
      end

      def model_string(model)
        if model
          model.local_network.name.ljust(20) + " " + model.date.strftime("%d/%m/%Y")
        else
          super
        end
      end
    end
  end
end
