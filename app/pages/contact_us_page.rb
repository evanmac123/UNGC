class ContactUsPage < ContainerPage

  def hero
    {
      title: {
        title1: 'Contact Us'
      },
      size: 'small',
      show_section_nav: true
    }
  end

  def meta_title
    'Contact Us'
  end

  def meta_description
  end

  def section_nav
    return Components::SectionNav.new(container)
  end
end
