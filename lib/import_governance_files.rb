# rails runner 'ImportGovernanceFiles.new.run' /path_to/file /path_to_files -e production
require 'csv'

class ImportGovernanceFiles
  def run

  abort "Usage: rails runner 'ImportGovernanceFiles.new.run' /path_to/file -e production" unless ARGV.any?
  file = ARGV.first
  path = ARGV.second

  if FileTest.exists?(file)
   # tab delimited so we can open in Excel
   puts "Network\tFilename\tResult\n"

    CSV.foreach(file, :headers => :first_row) do |row|
      network = LocalNetwork.find row["id"]
      if network

        file_path = "#{path}/#{row["filename"].rstrip}"
        result = "#{network.name}\t#{row["filename"]}\t"
        if FileTest.exists?(file_path)
          network.sg_annual_meeting_appointments_file = UploadedFile.new( :attachment => File.new(file_path),
                                                                          :attachable => network )
          result += "File saved\n" if network.save
        else
          result += "Governance file Not found\n"
        end
        puts result

      else
        puts "ID #{row["id"]} was not found\n"
      end

    end

  else
    puts "Input file not found"
  end

  end
end
