class SearchEscaper

  def self.escape(keywords)
    Riddle::Query.escape(String(keywords))
  end

end
