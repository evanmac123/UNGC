# ./script/runner 'ImportMouFiles.new.run' /path_to/file /path_to_mous -e production
require 'csv'

class ImportMouFiles
  def run

  abort "Usage: ./script/runner 'AssignNetworkLogins.new.run' /path_to/file -e production" unless ARGV.any?
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
          mou = Mou.new(:local_network_id => network.id, :year => "#{row["year"]}-01-01", :mou_type => 'accepted')
          mou.attachment = UploadedFile.new(:attachment => File.new(file_path))
          result += "File saved\n" if mou.save
        else
          result += "File Not found\n"
        end
        puts result

      else
        puts "ID #{row["id"]} was not found\n"
      end

    end

  else
    puts "File not found"
  end

  end
end
