module Searchable::SearchableFiles
  
  def safe_get_text_command(command, file)
    begin
      if File.exists?(file)
        text = `#{command} #{file}`.force_encoding('UTF-8')
      else
        text = '' # TODO: or raise?
      end
    rescue Exception => e
      logger.info " ** Unable to #{command}: #{file} because #{e.inspect}"
    ensure
      return text || ''
    end
  end
  
  def get_text_from_pdf(system_path_to_file)
    puts "Get from pdf #{system_path_to_file}"
    safe_get_text_command("pdf2txt.py", system_path_to_file)
  end
  
  def timestamps_from(system_path_to_file)
    if system_path_to_file
      object = OpenStruct.new
      mtime = File.mtime(system_path_to_file)
      object.created_at, object.updated_at = mtime, mtime
      object
    end
  end
  
  def get_text_from_word(system_path_to_file)
    puts "Get from Word #{system_path_to_file}"
    safe_get_text_command("#{RAILS_ROOT}/script/word_import", system_path_to_file)
  end
  
  def index_pdf(system_path_to_file, public_path_to_file)
    title = 'PDF File'
    url   = public_path_to_file
    content = get_text_from_pdf(system_path_to_file)
    object  = timestamps_from(system_path_to_file)
    import 'PDF', url: url, title: title, content: content, object: object
  end

end