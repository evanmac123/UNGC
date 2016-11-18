class CopFileImporter
  def run
    path = '/home/rails/ungc/uploaded/'

    cops = CommunicationOnProgress.joins('left join cop_files on cop_files.cop_id = communication_on_progresses.id')
                                  .where("identifier IS NOT NULL and related_document IS NOT NULL and related_document NOT LIKE '%COP.pdf'")
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
          cop.cop_files.create(:attachment => File.new(cop_file),
                               :attachment_type => CopFile::TYPES[:cop])
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
    cop_dir = '/home/rails/ungc/uploaded/cops_xml/'
    # cop_dir = '/Users/Shared/Downloads/cops_xml/'
    real_files = Dir.new(cop_dir).entries
    count = 0
    puts "*** Found #{real_files.count} COP files"
    real_files.each do |f|
      short = (f - '.xml').split('/').last
      puts "Working with file #{f}"
      if cop = CommunicationOnProgress.find_by_identifier(short)

        if cop.description.blank?
          puts "Found COP #{cop.id}: #{cop.title}"
          description_iso8859 = (Hpricot(open(cop_dir + f))/'description').inner_html
          description = description_iso8859.encode('UTF-8')
          count += 1 if !description.blank?
          cop.update_attribute :description, description.strip
        end

      else
        puts "  *** Error: Can't find the COP record #{short}"
      end
    end
    puts "*** Found #{count} COP descriptions"
  end

end
