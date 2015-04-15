class HighlightPage < ContainerPage

  def hero
    @data[:hero] || {}
  end

  def section_nav
    # Components::SectionNav.new(container)
    nav = {
      parent: {
        title: 'Participation',
        path: '/participation'
      },
      siblings: [
        {
          title: 'Sibling 1',
          path: ''
        },
        {
          title: 'Sibling 2',
          path: ''
        },
        {
          title: 'Current',
          path: '',
          is_current: true,
          children: [
            {
              title: 'Child Item 1',
              path: ''
            },
            {
              title: 'Child Item 2',
              path: ''
            },
            {
              title: 'Child Item 3',
              path: ''
            },
            {
              title: 'Child Item 4',
              path: ''
            },
          ]
        },
        {
          title: 'Sibling 4',
          path: ''
        },
        {
          title: 'Sibling 5',
          path: ''
        },
      ]
    }

    nav = OpenStruct.new(nav)

    nav.parent = OpenStruct.new(nav.parent)

    nav.siblings.map! do |ni|
      if ni[:is_current]
        ni[:children].map!{|c| OpenStruct.new(c)}
      end
      OpenStruct.new(ni)
    end

    nav
  end

  def main_content_sections
    @data[:article_blocks].map do |section|
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
