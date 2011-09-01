module Importers
  module LocalNetworks
    class EventAndActivityImporter < Base
      def worksheet_name
        "Event And Activity"
      end

      def init_model(row)
        get_local_network(row) do |local_network|
          get_value(row, "Event Title") do |title|
            title.present? && local_network.events.find_or_initialize_by_title(title)
          end
        end
      end

      def update_model(model, row)
        model.date                      = get_date(row, "Date")
        model.event_type                = get_value(row, "Type Of Event or Activity")
        model.num_participants          = get_integer(row, "Total Number Of Participants")
        model.gc_participant_percentage = get_integer(row, "Out Of Which, Approximate % Were GC Participants")

        principle_column_map = {
          "Human Rights"                => "Human Rights",
          "Labour Rights"               => "Labour",
          "Environment"                 => "Environment",
          "Anti-corruption"             => "Anti-Corruption",
          "Partnership for Development" => "Business for Development",
          "Other"                       => "Unknown"
        }

        principle_presence_map = {}

        principle_column_map.each_pair do |col_principle_name, db_principle_name|
          principle_presence_map[db_principle_name] = get_1(row, "Issue Area Cover(#{col_principle_name})")
        end

        if get_1(row, "Issue Area Cover(General (Addressing all Global Compact Issue Areas))")
          Principle.find_all_by_type("PrincipleArea").each do |principle_area|
            principle_presence_map[principle_area.name] = true
          end
        end

        principle_presence_map.each_pair do |principle_name, should_be_present|
          principle = Principle.find_by_name(principle_name)
          present   = model.principles.include?(principle)

          if present and !should_be_present
            model.principles.delete(principle)
          elsif !present and should_be_present
            model.principles << principle
          end
        end

        model.stakeholder_company              = get_1(row, "Stakeholder Group(Business)")
        model.stakeholder_sme                  = get_1(row, "Stakeholder Group(SMEs)")
        model.stakeholder_business_association = get_1(row, "Stakeholder Group(Business Associations)")
        model.stakeholder_labour               = get_1(row, "Stakeholder Group(Labour)")
        model.stakeholder_un_agency            = get_1(row, "Stakeholder Group(UN Agency)")
        model.stakeholder_ngo                  = get_1(row, "Stakeholder Group(NGOs)")
        model.stakeholder_foundation           = get_1(row, "Stakeholder Group(Foundations)")
        model.stakeholder_academic             = get_1(row, "Stakeholder Group(Academics)")
        model.stakeholder_government           = get_1(row, "Stakeholder Group(Government Entities)")
        model.stakeholder_media                = get_1(row, "Stakeholder Group(Media)")
        model.stakeholder_others               = get_1(row, "Stakeholder Group(Others)")

        unless model.attachment
          model.attachment = get_file(row, "Relevant Information of Event / Activity")
        end
      end

      def model_string(model)
        if model
          model.local_network.name + ": " + model.title
        else
          super
        end
      end

      def get_1(row, column_name)
        get_value(row, column_name) do |value|
          value == "1"
        end
      end
    end
  end
end

