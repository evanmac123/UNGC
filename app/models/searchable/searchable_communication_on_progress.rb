module Searchable::SearchableCommunicationOnProgress
  def index_communication_on_progress(cop)
    title   = cop.title
    url     = with_helper { cop_detail_path(:id => cop) }
    # import cop files
    file_content = []
    for file in cop.cop_files
      if file.attachment_content_type =~ /^application\/.*pdf$/
        file_content << get_text_from_pdf(file.attachment.path)
      elsif file.attachment_content_type =~ /doc/
        file_content << get_text_from_word(file.attachment.path)
      end
    end
    content = <<-EOF
      #{cop.description}
      #{cop.principles.map(&:name).join(' ')}
      #{cop.countries.map(&:name).join(' ')}
    EOF
    content = "#{content.force_encoding('UTF-8')} #{file_content.join(' ')}"
    
    import 'CommunicationOnProgress', url: url, title: title, content: content, object: cop
  end
  
  def index_communications_on_progress
    CommunicationOnProgress.approved.each { |cop| index_communication_on_progress cop }
  end

  def index_communications_on_progress_since(time)
    CommunicationOnProgress.approved.find(:all, conditions: new_or_updated_since(time)).each { |cop| index_communication_on_progress cop }
  end

end