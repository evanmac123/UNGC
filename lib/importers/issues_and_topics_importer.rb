require "importers/excel_importer"

module Importers
  module IssuesAndTopicsImporter
    class Base < ExcelImporter

      def worksheet_name
        "Sheet1"
      end

      def initialize(path)
        super(path)
        @cache = {}
      end

      def init_model(row)
        name = get_value(row,"name")
        id = get_integer(row,"id")
        p = Principle.find_or_initialize_by_name(name)
        @cache[id] = p
        p
      end

      def update_model(m,row)
        m.reference = get_value(row,"reference")
        parent = get_integer(row,"parent_id")
        m.parent_id = @cache[parent].id if parent
      end

      def get_integer(row, column_name)
        get_value(row, column_name) do |value|
          begin
            value.to_i
          rescue ArgumentError
            raise BadValue, "integer"
          end
        end
      end

    end
  end
end

