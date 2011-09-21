require "spreadsheet"

module Importers
  class ExcelImporter
    attr_accessor :log_file

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
          m = init_model(row)

          if m
            update_model(m, row)

            all_models = case m
                         when Array
                           m
                         when Hash
                           m.values
                         else
                           [m]
                         end

            all_models.each do |model|
              if model.changed?
                if model.save
                  report(row, model, "updated", :green, true)
                else
                  report(row, model, "validation failed", :red, false)
                end
              else
                report(row, model, "identical", :grey, true)
              end
            end
          else
            report(row, nil, "no model found", :yellow, false)
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

    def report(row, model, message, color, success)
      row_index = row.idx + 1
      model_str = model_string(model)

      line = "%8d %-35s %s" % [row_index, model_str[0..33], highlight(message, color)]

      $stderr.puts(line)

      if log_file
        success_str = success ? "SUCCESS" : "FAILURE"
        log_file.puts("#{success_str} - #{row_index} - #{message} - #{model_str}")
      end
    end

    def notice(message)
      log_file.puts("NOTICE - #{message}") if log_file
    end

    def warn(message)
      $stderr.puts(highlight(message, :yellow))
      log_file.puts("WARNING - #{message}") if log_file
    end

    def highlight(str, color=nil)
      return str unless color

      code = {
        black:   30, red:  31, green: 32, yellow: 33, blue: 34,
        magenta: 35, cyan: 36, white: 37, grey:   90
      }.fetch(color)

      "\033[#{code}m#{str}\033[m"
    end

    class BadValue < StandardError; end
  end
end

