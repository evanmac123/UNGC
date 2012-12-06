# ./script/runner 'AssignNetworkLogins.new.run' /path_to/file -e production
require 'csv'

class AssignNetworkLogins
  def run

  abort "Usage: ./script/runner 'AssignNetworkLogins.new.run' /path_to/file -e production" unless ARGV.any?
  file = ARGV.first

  if FileTest.exists?(file)
   # tab delimited so we can open in Excel
   puts ['Email', 'Username', 'Password', 'Name', 'Local Network / Organization', 'Status'].join("\t")

    CSV.foreach(file, :headers => :first_row) do |row|
      c = Contact.find_all_by_email(row["email"])
      unless c.any?
        puts "#{row["email"]}\t#{row["username"]}\t\t#{row["name"]}\t#{row["local_network"]}\tEmail not found"
      end

      c.each do |contact|
        if contact.from_network? && !contact.from_organization?
          if contact.update_attributes( :username => row["username"], :password => 'gcln' + contact.id.to_s )
            puts "#{contact.email}\t#{contact.login}\t#{contact.password}\t#{row["name"]}\t#{contact.organization_name}\tSuccess"
          end
        else
          puts "#{contact.email}\t#{row["username"]}\t\t#{row["name"]}\t#{contact.organization_name}\tNot a Local Network"
        end
      end

    end

  else
    puts "File not found"
  end

  end
end
