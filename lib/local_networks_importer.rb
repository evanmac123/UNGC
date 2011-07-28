if __FILE__ == $0 and ARGV.length != 1
  puts "usage: #{$0} DATA_FILE"
  exit -1
end
  
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require "spreadsheet"

class SpreadsheetImporter
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

class StructureGovernanceImporter < SpreadsheetImporter
  def worksheet_name
    "NetworkManagementAndFastFact"
  end

  def init_model(row)
    region = get_value(row, "Region Name")
    country_name = get_value(row, "Country Name")

    if region.present? and country_name.present?
      region = region[/\w+/].capitalize
      country = Country.find_by_region_and_name(region, country_name)

      if country
        country.local_network
      else
        puts "No country found: region = #{region.inspect}, name = #{country_name.inspect}"
        nil
      end
    else
      nil
    end
  end

  def update_model(model, row)
    model.sg_global_compact_launch_date = get_date(row, "Date Of Launch Of Global Compact In Country")
    model.sg_local_network_launch_date  = get_date(row, "Date Of Local Network Launch")
  end
end

if __FILE__ == $0
  StructureGovernanceImporter.new(*ARGV).run
end

