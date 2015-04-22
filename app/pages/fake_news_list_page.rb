class FakeNewsListPage
  def hero
    {
      size: 'small',
      title: {
        title1: "News &amp;",
        title2: "Press Releases"
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

  def news
    news = OpenStruct.new({
      title: "Press Releases",
      featured: {
        url: '',
        title: 'Global Compact LEAD Symposium Imagines the Future Corporation',
        date: '20 November 2014',
        location: 'New York, USA',
        blurb: 'Companies and sustainability experts sketched an outline of The Future Corporation the Global Compact LEAD Symposium.'
      },
      other: [{
        url: '',
        title: 'UN Global Compact Builds Momentum for Agribusiness and SDGs',
        date: '12 November 2014',
        location: 'New York, USA'
      },{
        url: '',
        title: 'UN Global Compact Builds Momentum for Agribusiness and SDGs',
        date: '12 November 2014',
        location: 'New York, USA'
      },{
        url: '',
        title: 'UN Global Compact Builds Momentum for Agribusiness and SDGs',
        date: '12 November 2014',
        location: 'New York, USA'
      },{
        url: '',
        title: 'UN Global Compact Builds Momentum for Agribusiness and SDGs',
        date: '12 November 2014',
        location: 'New York, USA'
      },{
        url: '',
        title: 'UN Global Compact Builds Momentum for Agribusiness and SDGs',
        date: '12 November 2014',
        location: 'New York, USA'
      },{
        url: '',
        title: 'UN Global Compact Builds Momentum for Agribusiness and SDGs',
        date: '12 November 2014',
        location: 'New York, USA'
      },{
        url: '',
        title: 'UN Global Compact Builds Momentum for Agribusiness and SDGs',
        date: '12 November 2014',
        location: 'New York, USA'
      },{
        url: '',
        title: 'UN Global Compact Builds Momentum for Agribusiness and SDGs',
        date: '12 November 2014',
        location: 'New York, USA'
      }]
    })

    news.featured = OpenStruct.new(news.featured)
    news.other.map!{|ni| OpenStruct.new(ni)}

    news
  end

  def sidebar_widgets
    {
      contact: {
        photo: "//ungc.s3.amazonaws.com/people/walid-nagi.jpg",
        name: "Mr. Walid Nagi",
        title: "Head Local Networks",
        email: "nagi@un.org",
        phone: "+1-212-907-1331"
      },
      links_lists: [{
        title: "Issue Background",
        links: [
          {
            label: "Article Link No. 1",
            url: ""
          },
          {
            label: "Article Link No. 2",
            url: ""
          },
          {
            label: "Article Link No. 3",
            url: ""
          },
          {
            label: "Article Link No. 4",
            url: ""
          },
          {
            label: "Article Link No. 5",
            url: ""
          }
        ]
      }, {
        title: "Learn More",
        links: [
          {
            label: "Article Link No. 1",
            url: ""
          },
          {
            label: "Article Link No. 2",
            url: ""
          },
          {
            label: "Article Link No. 3",
            url: ""
          },
          {
            label: "Article Link No. 4",
            url: ""
          },
          {
            label: "Article Link No. 5",
            url: ""
          }
        ]
      }],
      calls_to_action: [{
        label: "Join UN Global Compact Now",
        url: ""
      }, {
        label: "What You Can Do",
        url: ""
      }]
    }
  end

  def resources
    Resource.find [1,2,3]
  end

  def related_content
    rc = {
      related_content: {
        title: 'In The Media',
        content_boxes: [
          {
            container_path: "/about"
          },{
            container_path: "/"
          },{
            container_path: "/participation"
          }
        ]
      }
    }
    Components::RelatedContent.new(rc)
  end
end
