module Searchable::SearchableCommunicationOnProgress
  def index_communication_on_progress(cop)
    title   = cop.title
    url     = cop_url(cop)
    # import cop files
    file_content = []
    for file in cop.cop_files
      file_content << FileTextExtractor.extract(file)
    end
    content = <<-EOF
      #{cop.description}
      #{cop.principles.map(&:name).join(' ')}
      #{cop.countries.map(&:name).join(' ')}
    EOF

    str = file_content.join(' ')
    str.slice!(65000..-1) # edit str in place
    content = "#{content.force_encoding('UTF-8')} #{str}"

    import 'CommunicationOnProgress', url: url, title: title, content: content, object: cop
  end

  def index_communications_on_progress
    CommunicationOnProgress.approved.each { |cop| index_communication_on_progress cop }
  end

  def index_communications_on_progress_since(time)
    CommunicationOnProgress.approved.where(new_or_updated_since(time)).each { |cop| index_communication_on_progress cop }
  end

  def remove_communication_on_progress(cop)
    remove 'CommunicationOnProgress', cop_url(cop)
  end

  def cop_url(cop)
    with_helper { cop_detail_path(:id => cop) }
  end

end
