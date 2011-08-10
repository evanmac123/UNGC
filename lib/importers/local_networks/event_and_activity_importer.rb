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

