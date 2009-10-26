class FileImporter
  def import_commitment_letters(path)
    if File.directory? path
      Dir.foreach(path) do |file| 
        # we want files named like "welcome_letter_950.doc"
        next unless file.start_with? "welcome_letter"
        # we have a commitment letter
        old_tmp_id = file.split('_').last.split('.').first
        log "file: #{file}"
        if organization = Organization.find_by_old_tmp_id(old_tmp_id)
          organization.commitment_letter = File.new(File.join(path, file))
          organization.save
        end
      end
    end
  end
  
  private
    def log(string)
      puts "** #{string}"
    end
end