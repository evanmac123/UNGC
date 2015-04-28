class FakeAccordionPage
  def hero
    {
      size: 'small',
      title: {
        title1: "Think Globally.",
        title2: "Act Locally."
      },
      show_section_nav: true,
    }
  end

  def section_nav
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
          is_current: true
        },
        {
          title: 'Sibling 4',
          path: ''
        },
        {
          title: 'Sibling 5',
          path: ''
        },
      ],
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
    }

    nav = OpenStruct.new(nav)
    nav.parent = OpenStruct.new(nav.parent)
    nav.siblings.map!{|ni| OpenStruct.new(ni)}
    nav.children.map!{|ni| OpenStruct.new(ni)}

    nav
  end

  def accordion
    accordion = OpenStruct.new({
      title: "Frequently Asked Questions About Reporting",
      blurb: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed laoreet nunc dignissim quam tristique feugiat. Aliquam erat volutpat. Integer tristique, leo nec lobortis tincidunt, est lectus imperdiet lectus, ac blandit sem sapien id sem. Sed molestie justo et turpis facilisis, quis auctor dui suscipit. Nunc elementum lectus quis tincidunt gravida. Praesent velit est, aliquet volutpat sollicitudin accumsan, scelerisque ut turpis. Morbi bibendum nibh sit amet congue vestibulum.",
      items: [{
        title: 'UN Global Compact Builds Momentum',
        content: '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed laoreet nunc dignissim quam tristique feugiat. Aliquam erat volutpat.</p><p>Integer tristique, leo nec lobortis tincidunt, est lectus imperdiet lectus, ac blandit sem sapien id sem.</p><p>Sed molestie justo et turpis facilisis, quis auctor dui suscipit. Nunc elementum lectus quis tincidunt gravida. Praesent velit est, aliquet volutpat sollicitudin accumsan, scelerisque ut turpis. Morbi bibendum nibh sit amet congue vestibulum.</p>'
      },{
        title: 'This One Has Children',
        children: [{
          title: 'Some Child Title',
          content: '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed laoreet nunc dignissim quam tristique feugiat. Aliquam erat volutpat.</p><p>Iteger tristique, leo nec lobortis tincidunt, est lectus imperdiet lectus, ac blandit sem sapien id sem.</p><p>Sed molestie justo et turpis facilisis, quis auctor dui suscipit. Nunc elementum lectus quis tincidunt gravida. Praesent velit est, aliquet volutpat sollicitudin accumsan, scelerisque ut turpis. Morbi bibendum nibh sit amet congue vestibulum.</p>'
        },{
          title: 'Another Child Title But Longer To Test Wrapping And Stuffs But Looks Like It Needs To Be Even Longer',
          content: '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed laoreet nunc dignissim quam tristique feugiat. Aliquam erat volutpat.</p><p>Iteger tristique, leo nec lobortis tincidunt, est lectus imperdiet lectus, ac blandit sem sapien id sem.</p><p>Sed molestie justo et turpis facilisis, quis auctor dui suscipit. Nunc elementum lectus quis tincidunt gravida. Praesent velit est, aliquet volutpat sollicitudin accumsan, scelerisque ut turpis. Morbi bibendum nibh sit amet congue vestibulum.</p>'
        }]
      },{
        title: 'UN Global Compact Builds Momentum',
        content: '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed laoreet nunc dignissim quam tristique feugiat. Aliquam erat volutpat.</p><p>Integer tristique, leo nec lobortis tincidunt, est lectus imperdiet lectus, ac blandit sem sapien id sem.</p><p>Sed molestie justo et turpis facilisis, quis auctor dui suscipit. Nunc elementum lectus quis tincidunt gravida. Praesent velit est, aliquet volutpat sollicitudin accumsan, scelerisque ut turpis. Morbi bibendum nibh sit amet congue vestibulum.</p>'
      },{
        title: 'UN Global Compact Builds Momentum',
        content: '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed laoreet nunc dignissim quam tristique feugiat. Aliquam erat volutpat.</p><p>Integer tristique, leo nec lobortis tincidunt, est lectus imperdiet lectus, ac blandit sem sapien id sem.</p><p>Sed molestie justo et turpis facilisis, quis auctor dui suscipit. Nunc elementum lectus quis tincidunt gravida. Praesent velit est, aliquet volutpat sollicitudin accumsan, scelerisque ut turpis. Morbi bibendum nibh sit amet congue vestibulum.</p>'
      },{
        title: 'This Is Another Parent With A Way Longer Title So We Can See How It Behaves When It Has To Wrap',
        content: '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed laoreet nunc dignissim quam tristique feugiat. Aliquam erat volutpat.</p><p>Integer tristique, leo nec lobortis tincidunt, est lectus imperdiet lectus, ac blandit sem sapien id sem.</p><p>Sed molestie justo et turpis facilisis, quis auctor dui suscipit. Nunc elementum lectus quis tincidunt gravida. Praesent velit est, aliquet volutpat sollicitudin accumsan, scelerisque ut turpis. Morbi bibendum nibh sit amet congue vestibulum.</p>'
      },{
        title: 'UN Global Compact Builds Momentum',
        content: '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed laoreet nunc dignissim quam tristique feugiat. Aliquam erat volutpat.</p><p>Integer tristique, leo nec lobortis tincidunt, est lectus imperdiet lectus, ac blandit sem sapien id sem.</p><p>Sed molestie justo et turpis facilisis, quis auctor dui suscipit. Nunc elementum lectus quis tincidunt gravida. Praesent velit est, aliquet volutpat sollicitudin accumsan, scelerisque ut turpis. Morbi bibendum nibh sit amet congue vestibulum.</p>'
      },{
        title: 'UN Global Compact Builds Momentum',
        content: '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed laoreet nunc dignissim quam tristique feugiat. Aliquam erat volutpat.</p><p>Integer tristique, leo nec lobortis tincidunt, est lectus imperdiet lectus, ac blandit sem sapien id sem.</p><p>Sed molestie justo et turpis facilisis, quis auctor dui suscipit. Nunc elementum lectus quis tincidunt gravida. Praesent velit est, aliquet volutpat sollicitudin accumsan, scelerisque ut turpis. Morbi bibendum nibh sit amet congue vestibulum.</p>'
      },{
        title: 'UN Global Compact Builds Momentum',
        content: '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed laoreet nunc dignissim quam tristique feugiat. Aliquam erat volutpat.</p><p>Integer tristique, leo nec lobortis tincidunt, est lectus imperdiet lectus, ac blandit sem sapien id sem.</p><p>Sed molestie justo et turpis facilisis, quis auctor dui suscipit. Nunc elementum lectus quis tincidunt gravida. Praesent velit est, aliquet volutpat sollicitudin accumsan, scelerisque ut turpis. Morbi bibendum nibh sit amet congue vestibulum.</p>'
      }]
    })

    accordion.items.map! do |ni|
      if ni[:children]
        ni[:children].map!{|child| OpenStruct.new(child)}
      end
      OpenStruct.new(ni)
    end

    accordion
  end

  def sidebar_widgets
    widgets = {}

    # widgets[:links_lists] = Components::LinksLists.new(@data).data

    widgets
  end
end
