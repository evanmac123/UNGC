class CopFileImporter
  def run
    path = '/Users/Shared/Downloads/'    
    conditions = "identifier IS NOT NULL and related_document IS NOT NULL and related_document NOT LIKE '%COP.pdf'"
    
    cops = CommunicationOnProgress.find(:all, :joins => 'left join cop_files on cop_files.cop_id = communication_on_progresses.id', :conditions =>  conditions)
    puts "Found #{cops.count} COPs\n"
    missing = 0
    found = 0
    
    cops.each do |cop|
      
      if cop.cop_files.count == 0
        missing += 1 
        cop_file = File.join(path, cop.related_document)
        if File.exist?(cop_file)
          found += 1
          puts "Found: #{cop_file}\n"
          # cop.cop_files.create(:attachment => File.new(cop_file),
          #                      :attachment_type => CopFile::TYPES[:cop])
        end
      end
    end

    puts "#{missing} have no file\n"
    puts "#{found} files have been found\n"
    puts "#{missing.to_i - found.to_i} are missing\n"
  end
  
  def import_cop_xml
    require 'hpricot'
    require 'facets'
    puts "*** Importing from cop_xml data..."
    real_files = @path + ""
    converter = Iconv.new("UTF-8", "iso8859-1")
    real_files.each do |f|
      short = (f - '.xml').split('/').last
      # puts "Working with file #{short}:"
      if cop = CommunicationOnProgress.find_by_identifier(short)
        description = converter.iconv (Hpricot(open(f))/'description').inner_html
        # cop.update_attribute :description, description.strip
      else
        # puts "  *** Error: Can't find the COP"
      end
      # puts "\n"
    end
    # puts "*** Done!"
  end
  
end