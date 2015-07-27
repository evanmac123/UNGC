class SearchEscaper

  def self.escape(keywords)
    Riddle::Query.escape(sanitize_keywords(keywords))
  end

  private

  # TODO fix utf-8 properly or refactor this
  def self.sanitize_keywords(keywords)
    String(keywords).gsub(/'/,'').gsub(/’/,'')
  end

end
