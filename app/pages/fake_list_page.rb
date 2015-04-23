class FakeListPage
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

  def list
    list = OpenStruct.new({
      title: "Local Network Annual Reports",
      blurb: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed laoreet nunc dignissim quam tristique feugiat. Aliquam erat volutpat. Integer tristique, leo nec lobortis tincidunt, est lectus imperdiet lectus, ac blandit sem sapien id sem. Sed molestie justo et turpis facilisis, quis auctor dui suscipit. Nunc elementum lectus quis tincidunt gravida. Praesent velit est, aliquet volutpat sollicitudin accumsan, scelerisque ut turpis. Morbi bibendum nibh sit amet congue vestibulum.",
      items: [{
        url: '',
        title: 'UN Global Compact Builds Momentum for Agribusiness and SDGs',
        type: 'pdf',
        blurb: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed laoreet nunc dignissim quam tristique feugiat. Aliquam erat volutpat. Integer tristique, leo nec lobortis tincidunt, est lectus imperdiet lectus, ac blandit sem sapien id sem. Sed molestie justo et turpis facilisis, quis auctor dui suscipit. Nunc elementum lectus quis tincidunt gravida. Praesent velit est, aliquet volutpat sollicitudin accumsan, scelerisque ut turpis. Morbi bibendum nibh sit amet congue vestibulum.'
      },{
        url: '',
        title: 'UN Global Compact Builds Momentum for Agribusiness and SDGs',
        type: 'pdf',
        blurb: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed laoreet nunc dignissim quam tristique feugiat. Aliquam erat volutpat. Integer tristique, leo nec lobortis tincidunt, est lectus imperdiet lectus, ac blandit sem sapien id sem. Sed molestie justo et turpis facilisis, quis auctor dui suscipit. Nunc elementum lectus quis tincidunt gravida. Praesent velit est, aliquet volutpat sollicitudin accumsan, scelerisque ut turpis. Morbi bibendum nibh sit amet congue vestibulum.',
        image: 'https://www.unglobalcompact.org/system/resources/images/1151/show@2x/resource_preview_1151.png'
      },{
        url: '',
        title: 'UN Global Compact Builds Momentum for Agribusiness and SDGs',
        type: 'pdf',
        blurb: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed laoreet nunc dignissim quam tristique feugiat. Aliquam erat volutpat. Integer tristique, leo nec lobortis tincidunt, est lectus imperdiet lectus, ac blandit sem sapien id sem. Sed molestie justo et turpis facilisis, quis auctor dui suscipit. Nunc elementum lectus quis tincidunt gravida. Praesent velit est, aliquet volutpat sollicitudin accumsan, scelerisque ut turpis. Morbi bibendum nibh sit amet congue vestibulum.'
      },{
        url: '',
        title: 'UN Global Compact Builds Momentum for Agribusiness and SDGs',
        type: 'pdf',
        blurb: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed laoreet nunc dignissim quam tristique feugiat. Aliquam erat volutpat. Integer tristique, leo nec lobortis tincidunt, est lectus imperdiet lectus, ac blandit sem sapien id sem. Sed molestie justo et turpis facilisis, quis auctor dui suscipit. Nunc elementum lectus quis tincidunt gravida. Praesent velit est, aliquet volutpat sollicitudin accumsan, scelerisque ut turpis. Morbi bibendum nibh sit amet congue vestibulum.'
      },{
        url: '',
        title: 'UN Global Compact Builds Momentum for Agribusiness and SDGs',
        type: 'pdf',
        blurb: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed laoreet nunc dignissim quam tristique feugiat. Aliquam erat volutpat. Integer tristique, leo nec lobortis tincidunt, est lectus imperdiet lectus, ac blandit sem sapien id sem. Sed molestie justo et turpis facilisis, quis auctor dui suscipit. Nunc elementum lectus quis tincidunt gravida. Praesent velit est, aliquet volutpat sollicitudin accumsan, scelerisque ut turpis. Morbi bibendum nibh sit amet congue vestibulum.'
      },{
        url: '',
        title: 'UN Global Compact Builds Momentum for Agribusiness and SDGs',
        type: 'pdf',
        blurb: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed laoreet nunc dignissim quam tristique feugiat. Aliquam erat volutpat. Integer tristique, leo nec lobortis tincidunt, est lectus imperdiet lectus, ac blandit sem sapien id sem. Sed molestie justo et turpis facilisis, quis auctor dui suscipit. Nunc elementum lectus quis tincidunt gravida. Praesent velit est, aliquet volutpat sollicitudin accumsan, scelerisque ut turpis. Morbi bibendum nibh sit amet congue vestibulum.',
        image: 'https://www.unglobalcompact.org/system/resources/images/1131/show@2x/resource_preview_1131.png'
      },{
        url: '',
        title: 'UN Global Compact Builds Momentum for Agribusiness and SDGs',
        type: 'pdf',
        blurb: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed laoreet nunc dignissim quam tristique feugiat. Aliquam erat volutpat. Integer tristique, leo nec lobortis tincidunt, est lectus imperdiet lectus, ac blandit sem sapien id sem. Sed molestie justo et turpis facilisis, quis auctor dui suscipit. Nunc elementum lectus quis tincidunt gravida. Praesent velit est, aliquet volutpat sollicitudin accumsan, scelerisque ut turpis. Morbi bibendum nibh sit amet congue vestibulum.'
      },{
        url: '',
        title: 'UN Global Compact Builds Momentum for Agribusiness and SDGs',
        type: 'pdf',
        blurb: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed laoreet nunc dignissim quam tristique feugiat. Aliquam erat volutpat. Integer tristique, leo nec lobortis tincidunt, est lectus imperdiet lectus, ac blandit sem sapien id sem. Sed molestie justo et turpis facilisis, quis auctor dui suscipit. Nunc elementum lectus quis tincidunt gravida. Praesent velit est, aliquet volutpat sollicitudin accumsan, scelerisque ut turpis. Morbi bibendum nibh sit amet congue vestibulum.'
      }]
    })

    list.items.map!{|ni| OpenStruct.new(ni)}

    list
  end
end
