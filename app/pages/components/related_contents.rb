class Components::RelatedContents
  include Enumerable

  def initialize(data)
    @data = data
  end


  def boxes
    data.map { |c| Components::RelatedContent.new(c) }
  end

  def each(&block)
    boxes.each do |b|
      block.call(b)
    end
  end

  private

  def data
    @data[:related_contents] || []
  end

end
