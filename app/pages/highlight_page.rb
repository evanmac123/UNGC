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
      self.class.prepare_block_for_display(section)
    end
  end

  def resources
    Components::Resources.new(@data).data
  end

  def self.prepare_block_for_display(section)
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

  private

  def self.section_classes(section)
    classes = []
    classes << 'has-custom-bg' if section[:bg_image]
    classes << "align-#{section[:align]}" if section[:align]
    classes << "#{section[:theme]}-theme" if section[:theme]
    classes.join(' ')
  end

  def self.section_styles(section)
    section[:bg_image] ? "background-image: url(#{section[:bg_image]})" : ''
  end
end
