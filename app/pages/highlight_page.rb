class HighlightPage < ContainerPage

  def hero
    @data[:hero] || {}
  end

  def section_nav
    return Components::SectionNav.new(container)
  end

  def main_content_sections
    article_blocks = @data[:article_blocks] || []
    article_blocks.map do |section|
      data = {
        title: section[:title],
        content: section[:content],
        classes: section_classes(section),
        styles: section_styles(section)
      }
      cta = section[:call_to_action]
      data[:call_to_action] = cta if cta && cta[:enabled]
      data[:image] = section[:widget_image] if section[:widget_image]
      data
    end
  end

  private

  def section_classes(section)
    classes = []
    classes << 'has-custom-bg' if section[:bg_image]
    classes << "align-#{section[:align]}" if section[:align]
    classes << "#{section[:theme]}-theme" if section[:theme]
    classes.join(' ')
  end

  def section_styles(section)
    section[:bg_image] ? "background-image: url(#{section[:bg_image]})" : ''
  end
end
