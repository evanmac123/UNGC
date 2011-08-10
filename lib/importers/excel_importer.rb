require "spreadsheet"

module Importers
  class ExcelImporter
    def initialize(path)
      @path = path
    end

    def run
      $stderr.puts
      $stderr.puts highlight("Importing #{worksheet_name}", :blue)
      $stderr.puts

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
        value = row[index].strip
        return nil if value.empty?

        return value unless block_given?

        begin
          yield(value)
        rescue BadValue => e
          msg = if e.message
                  "Bad #{e.message} value"
                else
                  "Bad value"
                end

          msg << " on row \##{row.idx}, column name #{column_name.inspect}: #{value.inspect}"

          warn(msg)
          nil
        end
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
      line = "#{row.idx.to_s.rjust(8)} "

      line << model_string(model)[0..33].ljust(35)

      message = message.ljust(20)
      message = highlight(message, color) if color
      line << message

      $stderr.puts(line)
    end

    def warn(message)
      $stderr.puts(highlight(message, :yellow))
    end

    def highlight(str, color)
      code = {
        black:   30, red:  31, green: 32, yellow: 33, blue: 34,
        magenta: 35, cyan: 36, white: 37, grey:   90
      }.fetch(color)

      "\033[#{code}m#{str}\033[m"
    end

    class BadValue < StandardError; end
  end
end

