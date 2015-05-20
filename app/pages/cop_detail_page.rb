class CopDetailPage < SimpleDelegator

  attr_reader :container

  def hero
    {size: 'small'}
  end

  def meta_title
    'COP Detail'
  end

  def meta_description
  end

  # def section_nav
  #   return Components::SectionNav.new(container)
  # end
end
