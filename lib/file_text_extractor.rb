require 'timeout'
require 'tempfile'

module FileTextExtractor
  PROCESS_TIMEOUT = 20

  module_function

  def extract(model)
    if model.attachment_content_type =~ /^application\/.*pdf$/
      get_text_from_pdf(model.attachment.path)
    elsif model.attachment_content_type =~ /\b(doc|msword)\b/
      get_text_from_word(model.attachment.path)
    end
  end

  def get_text_from_pdf(path)
    Rails.logger.info "Extracting text from PDF: #{path.inspect}"
    safe_get_text_command("pdf2txt.py", path)
  end

  def get_text_from_word(path)
    Rails.logger.info "Extracting text from Word: #{path.inspect}"
    safe_get_text_command("#{Rails.root}/script/word_import", path)
  end

  def safe_get_text_command(command, file)
    begin
      full_command = "#{command} '#{file}'"
      pid          = nil
      text         = ""

      if File.exists?(file)
        output = Timeout.timeout(PROCESS_TIMEOUT) do
          Tempfile.open("FileTextExtractor.out") do |out|
            Tempfile.open("FileTextExtractor.err") do |err|
              Rails.logger.info "Spawning #{full_command.inspect}, redirecting stdout to #{out.path}, stderr to #{err.path}"

              pid = Process.spawn(full_command, :out => out.path, :err => err.path)
              Process.wait(pid)

              unless $?.success?
                Rails.logger.error "Process exited with status #{$?.to_s.inspect}: #{full_command}"
                Rails.logger.error "Stderr output: #{File.read(err.path)}"
              end

              File.read(out.path, encoding: 'ASCII-8BIT')
            end
          end
        end

        text = Iconv.conv('utf-8//IGNORE', 'utf-8', output.force_encoding('UTF-8'))
      else
        Rails.logger.error "File does not exist: #{file.inspect}"
      end
    rescue StandardError => e
      Process.kill(9, pid) if pid
      Rails.logger.error "Unable to execute #{full_command.inspect} because of #{e.class.name}: #{e.message}"
    ensure
      return text
    end
  end
end

