require "spreadsheet"

module Importers
  class ExcelImporter
    def initialize(path)
      @path = path
    end

    def run
      workbook  = Spreadsheet.open(@path)
      worksheet = workbook.worksheet(self.worksheet_name)

      @column_names = nil

      worksheet.each do |row|
        if @column_names.nil?
          @column_names = row
        else
          model = init_model(row)

          if model
            model_str = "#{model.class.name} with id=#{model.id}:"

            update_model(model, row)

            if model.changed?
              if model.save
                puts "#{model_str} updated"
              else
                puts "#{model_str} validation failed"
              end
            else
              puts "#{model_str} identical"
            end
          else
            puts "No model found for row \##{row.idx}"
          end
        end
      end
    end

    def get_value(row, column_name)
      if index = @column_names.index(column_name)
        row[index]
      else
        puts "Column not found: #{column_name.inspect}"
        nil
      end
    end

    def get_date(row, column_name)
      value = get_value(row, column_name).strip

      if value == ""
        nil
      elsif value =~ %r{^(\d{1,2})/(\d{1,2})/(\d{4})}
        Date.strptime(value, "%d/%m/%Y")
      else
        puts "Bad date on row \##{row.idx}, column #{column_name.inspect}: #{value.inspect}"
        nil
      end
    end

    class InvalidData < StandardError; end
  end
end

