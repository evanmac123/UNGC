module Importers
  module LocalNetworks
    class IntegrityMeasureAndAwardImporter < Base
      def worksheet_name
        "Integrity Measure And Award"
      end

      def init_model(row)
        get_local_network(row) do |local_network|
          models = {}

          if get_yesno(row, "Policies on Network Involvement In Communication on Progress")
            models[:cop] = local_network.integrity_measures.find_or_initialize_by_policy_type("cop")
          end

          if get_yesno(row, "Does The Network have a Specific Logo Policy?")
            models[:logo] = local_network.integrity_measures.find_or_initialize_by_policy_type("logo")
          end

          if get_yesno(row, "Does GCLN Have A Policy On Dialogue Facilitation?")
            models[:dialogue] = local_network.integrity_measures.find_or_initialize_by_policy_type("dialogue")
          end

          if get_yesno(row, "Has Network Been Involved In Awards/ Recognition Mechanism")
            if date = get_date(row, "Award Date", :middle)
              models[:award] = local_network.awards.find_or_initialize_by_date(date)
            end
          end

          models
        end
      end

      def update_model(models, row)
        [:cop, :logo, :dialogue].each do |type|
          if models[type]
            models[type].attributes = {
              title:        IntegrityMeasure::TYPES[type],
              policy_type:  type.to_s,
              description:  "Not specified",
              date:         Date.today
            }
          end
        end

        if models[:award]
          models[:award].attributes = {
            title: "Award",
            description: "Not specified"
          }
        end
      end

      def model_string(model)
        if model
          type_string = case model
                        when IntegrityMeasure
                          model.policy_type
                        when Award
                          "award"
                        end

          model.local_network.name.ljust(20) + ": " + type_string
        else
          super
        end
      end
    end
  end
end
