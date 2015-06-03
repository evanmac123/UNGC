class EmptySearch

  def method_missing(*args)
    self
  end

  def any?
    false
  end

  def none?
    false
  end

  def total_pages
    0
  end

end
