# frozen_string_literal: true

require 'timeout'
require 'tempfile'

class FileTextExtractor
  @timeout = 20
  class << self
    attr_accessor :timeout
  end

  def self.extract(model)
    type, path = mime_type_from_ole_storage(model)

    extractor = FileTextExtractor.new
    case
    when type =~ /^application\/.*pdf$/
      extractor.get_text_from_pdf(path)
    when type =~ /application\/vnd\.openxmlformats-officedocument\.wordprocessingml\.document/
      extractor.get_text_from_docx(path)
    when type =~ /\b(doc|msword)\b/
      extractor.get_text_from_word(path)
    when type =~ /application\/vnd\.openxmlformats-officedocument\.presentationml\.presentation/
      extractor.get_text_from_pptx(path)
    when type =~ /application\/vnd\.ms-powerpoint/
      extractor.get_text_from_ppt(path)
    else
      Rails.logger.error "Unknown content-type: #{type}"
    end
  end

  OLE_MIME_TYPES = %w[application/x-msword application/vnd.ms-powerpoint application/vnd.ms-excel]

  def self.mime_type_from_ole_storage(model)
    # Refer to:
    # https://github.com/minad/mimemagic/issues/50
    # https://github.com/thoughtbot/paperclip/issues/2414
    # https://github.com/minad/mimemagic/pull/52 (as of 11-Feb-108 unmerged)
    type = model.attachment_content_type
    path = model.attachment.path

    if type =~ /application\/x-ole-storage/
      possible_types = MIME::Types.type_for(path).collect(&:content_type)
      OLE_MIME_TYPES.each { |ole_mime_type| return ole_mime_type, path if possible_types.include?(ole_mime_type) }
    end

    return type, path
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

  def get_text_from_ppt(path)
    Rails.logger.info "Extracting text from Powerpoint: #{path.inspect}"
    safe_get_text_command("#{Rails.root}/script/ppt_import", path)
  end

  def get_text_from_pptx(path)
    Rails.logger.info "Extracting text from Powerpoint (New Format): #{path.inspect}"
    safe_get_text_command("#{Rails.root}/script/pptx_import", path)
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

        text = output.force_encoding('UTF-8').encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "?")
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

