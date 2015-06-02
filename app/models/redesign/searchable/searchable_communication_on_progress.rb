class Redesign::Searchable::SearchableCommunicationOnProgress < Redesign::Searchable::Base
  alias_method :cop, :model

  def self.all
    CommunicationOnProgress.approved
  end

  def document_type
    'CommunicationOnProgress'
  end

  def title
    cop.title
  end

  def url
    remove_redesign_prefix show_redesign_cops_path(differentiation: cop.differentiation_level_with_default, id: cop.id)
  end

  def content
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
  end

end
