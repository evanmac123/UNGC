require 'rexml/document'

class FileImporter
  # path is the folder where all uploaded files are located
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
  
  # path is the folder where all uploaded files are located
  def import_logo_samples(path)
    if File.directory? path
      Dir.foreach(path) do |file|
        # we want files named like "logo_request_sample_68_74.jpg"
        # 68 is logo_requests.old_id
        # 74 is logo_comments.old_id
        next unless file.start_with? "logo_request_sample"
        # we have a logo sample
        old_logo_comment_id = file.split('_').last.split('.').first
        log "file: #{file}"
        if logo_comment = LogoComment.find_by_old_id(old_logo_comment_id)
          logo_comment.attachment = File.new(File.join(path, file))
          # we don't want validations here
          logo_comment.save(false)
        end
      end
    end
  end
    
  # path is the folder that contain the doc and xml folder for case stories
  def import_case_stories(path)
    if File.directory? path
      CaseStory.all.each do |case_story|
        # let's try to find the XML file for this case story
        xml_file = File.join(path, "xml", "#{case_story.identifier}.xml")
        if File.exist?(xml_file)
          begin
            doc = REXML::Document.new(File.new(xml_file))
            # there's a single element
            case_story.description = doc.elements.first.text
          rescue
            log "Invalid xml file #{xml_file}"
          end
        end
        # user uploaded DOC/PDF for this case story
        [:doc, :pdf, :ptt].each do |extension|
          doc_file = File.join(path, "doc", "#{case_story.identifier}.#{extension}")
          if File.exist?(doc_file)
            case_story.attachment = File.new(doc_file)
          end
        end

        case_story.save
      end
    end
  end

  private
    def log(string)
      puts "** #{string}"
    end
end