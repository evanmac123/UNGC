module Redesign::Searchable::SearchableCommunicationOnProgress
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
    content = "#{content.force_encoding('UTF-8')} #{file_content.join(' ')}"

    import 'CommunicationOnProgress', url: url, title: title, content: content
  end

  def index_communications_on_progresses
    CommunicationOnProgress.approved.take(10).each { |cop| index_communication_on_progress cop }
  end

  def index_communications_on_progress_since(time)
    CommunicationOnProgress.approved.where(new_or_updated_since(time)).each { |cop| index_communication_on_progress cop }
  end

  def remove_communication_on_progress(cop)
    remove 'CommunicationOnProgress', cop_url(cop)
  end

  def cop_url(cop)
    with_helper { show_redesign_cops_path(type: cop.cop_type, id: cop.id) }
  end

end

