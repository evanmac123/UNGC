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
            update_model(model, row)

            if model.changed?
              if model.save
                report(row, model, "updated", :green)
              else
                report(row, model, "validation failed", :red)
              end
            else
              report(row, model, "identical", :grey)
            end
          else
            report(row, nil, "no model found", :yellow)
          end
        end
      end
    end

    def get_value(row, column_name)
      if index = @column_names.index(column_name)
        row[index]
      else
        warn "Column not found: #{column_name.inspect}"
        nil
      end
    end

    def model_string(model)
      if model
        "#{model.class.name}(#{model.id})"
      else
        ""
      end
    end

    def report(row, model, message, color)
      line = "Row: #{row.idx.to_s.rjust(4)} "

      line << model_string(model).ljust(20)

      message = message.ljust(20)
      message = highlight(message, color) if color
      line << message

      $stderr.puts(line)
    end

    def warn(message)
      $stderr.puts(" * " + highlight(message, :yellow))
    end

    def highlight(str, color)
      code = {
        black:   30, red:  31, green: 32, yellow: 33, blue: 34,
        magenta: 35, cyan: 36, white: 37, grey:   90
      }.fetch(color)

      "\033[#{code}m#{str}\033[m"
    end

    class InvalidData < StandardError; end
  end
end

