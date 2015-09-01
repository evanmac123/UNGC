class SearchEscaper

  def self.escape(keywords)
    Riddle::Query.escape(keywords)
  end

end
