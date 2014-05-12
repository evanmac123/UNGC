require 'timeout'
require 'tempfile'

class FileTextExtractor
  @timeout = 20
  class << self
    attr_accessor :timeout
  end

  def self.extract(model)
    type = model.attachment_content_type
    path = model.attachment.path

    extractor = FileTextExtractor.new
    if type =~ /^application\/.*pdf$/
      extractor.get_text_from_pdf(path)
    elsif type =~ /application\/vnd\.openxmlformats-officedocument\.wordprocessingml\.document/
      extractor.get_text_from_docx(path)
    elsif type =~ /\b(doc|msword)\b/
      extractor.get_text_from_word(path)
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

  def get_text_from_docx(path)
    Rails.logger.info "Extracting text from Word (New Format): #{path.inspect}"
    safe_get_text_command("#{Rails.root}/script/docx_import", path)
  end

  private

  def safe_get_text_command(command, file)
    begin
      full_command = "#{command} '#{file}'"
      pid          = nil
      text         = ""

      if File.exists?(file)
        output = Timeout.timeout(timeout) do
          Tempfile.open("FileTextExtractor.out") do |out|
            Tempfile.open("FileTextExtractor.err") do |err|
              Rails.logger.info "Spawning #{full_command.inspect}, redirecting stdout to #{out.path}, stderr to #{err.path}"

              pid = Process.spawn(full_command, :out => out.path, :err => err.path, :pgroup => true)
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
    rescue => e
      Rails.logger.error "Unable to execute #{full_command.inspect} because of #{e.class.name}: #{e.message}"
      if pid
        # kill the process group that was created for this task
        # detach from the pid as we don't care about the result
        pgid = Process.getpgid(pid)
        Process.kill(-9,pgid)
        Process.detach(pid)
      end
    ensure
      return text
    end
  end

  def timeout
    self.class.timeout
  end

end

