require 'rexml/document'

class FileImporter
  # path is the folder where all uploaded files are located
  def import_commitment_letters(unapproved_orgs_path, approved_orgs_path)
    # this works for organizations that are not yet approved
    if File.directory? unapproved_orgs_path
      Dir.foreach(unapproved_orgs_path) do |file|
        # we want files named like "welcome_letter_950.doc"
        next unless file.start_with? "welcome_letter"
        # we have a commitment letter
        old_tmp_id = file.split('_').last.split('.').first
        log "file: #{file}"
        if organization = Organization.find_by_old_tmp_id(old_tmp_id)
          organization.commitment_letter = File.new(File.join(unapproved_orgs_path, file))
          organization.save
        end
      end
    end
    # this works for organizations that are approved
    if File.directory? approved_orgs_path
      Dir.foreach(approved_orgs_path) do |file|
        # we want files named like "Global_Compact_Join_Letter_8114.pdf"
        next unless file.start_with? "Global_Compact_Join_Letter"
        # we have a commitment letter
        old_id = file.split('_').last.split('.').first
        log "file: #{file}"
        if organization = Organization.find_by_old_id(old_id)
          organization.commitment_letter = File.new(File.join(approved_orgs_path, file))
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

  def import_cop_xml(path = nil)
    require 'hpricot'
    require 'facets'
    # puts "*** Importing from cop_xml data..."
    real_files = Dir[path || DEFAULTS[:path_to_cop_xml]]
    converter = Iconv.new("UTF-8", "iso8859-1")
    real_files.each do |f|
      short = (f - '.xml').split('/').last
      # puts "Working with file #{short}:"
      if cop = CommunicationOnProgress.find_by_identifier(short)
        description = converter.iconv (Hpricot(open(f))/'description').inner_html
        cop.update_attribute :description, description.strip
      else
        # puts "  *** Error: Can't find the COP"
      end
      # puts "\n"
    end
    # puts "*** Done!"
  end

  private
    def log(string)
      puts "** #{string}"
    end
end