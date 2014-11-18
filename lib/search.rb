class Search

  def self.running?
    ThinkingSphinx::Configuration.instance.controller.running?
  end

end
