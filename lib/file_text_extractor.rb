module FileTextExtractor
  module_function

  def extract(model)
    if model.attachment_content_type =~ /^application\/.*pdf$/
      get_text_from_pdf(model.attachment.path)
    elsif model.attachment_content_type =~ /doc|msword/
      get_text_from_word(model.attachment.path)
    end
  end

  def get_text_from_pdf(path)
    Rails.logger.info "Extracting text from PDF: #{path.inspect}"
    safe_get_text_command("pdf2txt.py", path)
  end

  def get_text_from_word(path)
    Rails.logger.info "Extracting text from Word: #{path.inspect}"
    safe_get_text_command("#{RAILS_ROOT}/script/word_import", path)
  end

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
end

