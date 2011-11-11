# ./script/runner 'AssignNetworkLogins.new.run' -e production
require 'csv'

class AssignNetworkLogins
  def run

  abort "Usage: ./script/runner 'AssignNetworkLogins.new.run' '/path_to/file' -e production" unless ARGV.any?
  file = ARGV.first
  
  if FileTest.exists?(file)

    CSV.foreach(file, :headers => :first_row) do |row|
      c = Contact.find_all_by_email(row["email"])
      if c.count > 1
        puts "Duplicate: #{row["email"]}"        
      elsif c.count == 1
        contact = c.first
        puts "Updated:     #{contact.name}\t\t\t#{'gcln' + contact.id.to_s}" if contact.update_attributes( :login => row["username"], :password => 'gcln' + contact.id.to_s )
      else
        puts "No Match:  #{row["email"]}"
      end
    end

  else
    puts "File not found"
  end

  end
end