class FakeNewsLandingPage
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
      }]
    })

    news.featured = OpenStruct.new(news.featured)
    news.other.map!{|ni| OpenStruct.new(ni)}

    news
  end

  def main_content_section
    {
      title: "Press Releases",
      content: "<p>At minus excepturi nostrum ut cupiditate expedita enim repellat necessitatibus cumque ad sint pariatur. et quo fuga saepe recusandae quasi. dolorem odit assumenda aspernatur ea qui ratione possimus quis quis reprehenderit. dolorem qui amet cum doloremque sed occaecati ut. non quia iusto provident. asperiores quae ut quod culpa quibusdam rerum</p><p>Accusamus nihil magni nihil sint odio eligendi fugiat id officia quia deleniti nesciunt. fugit nulla aut quo harum perferendis iusto impedit perferendis architecto perferendis iusto sint animi. repudiandae itaque omnis ratione ex ut ipsum architecto aut vel ab accusantium inventore odio ea</p>"
    }
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

  def events
    [
      {
        url: "",
        title: "6th Annual Women&rsquo;s Empowerment Principles Event: Gender Equality and the Global Jobs Challenge",
        date: "12 December 2014",
        location: "New York, NY, USA",
        excerpt: "Spotlights business strategies, experience, and challenges on increasing and enhancing job opportunities for women and expanding access to decent jobs.",
        thumbnail: "//ungc.s3.amazonaws.com/womens-empowerment.jpg"
      },
      {
        url: "",
        title: "CEO Water Mandate Multi-Stakeholder Working Conference",
        date: "8&hairsp;&ndash;&hairsp;10 April 2015",
        location: "Lima, Peru",
        excerpt: "Spotlights business strategies, experience, and challenges on increasing and enhancing job opportunities for women and expanding access to decent jobs.",
        thumbnail: "//ungc.s3.amazonaws.com/womens-empowerment.jpg"
      },
      {
        url: "",
        title: "Annual Conference&hairsp;&mdash;&hairsp;Children&rsquo;s Rights and Business Principles",
        date: "12 May 2015",
        location: "Nairobi, Kenya",
        excerpt: "Spotlights business strategies, experience, and challenges on increasing and enhancing job opportunities for women and expanding access to decent jobs.",
        thumbnail: "//ungc.s3.amazonaws.com/womens-empowerment.jpg"
      },
      {
        url: "",
        title: "CEO Water Mandate Multi-Stakeholder Working Conference",
        date: "24&hairsp;&ndash;&hairsp;26 June 2015",
        location: "Jakarta, Indonesia",
        excerpt: "Spotlights business strategies, experience, and challenges on increasing and enhancing job opportunities for women and expanding access to decent jobs.",
        thumbnail: "//ungc.s3.amazonaws.com/womens-empowerment.jpg"
      }
    ]
  end

  def participants
    [
      {
        name: 'A. Amigos de Silva',
        sector: 'Public Sector',
        country: 'Spain',
        url: ''
      },
      {
        name: 'A. Amigos de Silva',
        sector: 'Public Sector',
        country: 'Spain',
        url: ''
      },
      {
        name: 'A. Amigos de Silva',
        sector: 'Public Sector',
        country: 'Spain',
        url: ''
      },
      {
        name: 'A. Amigos de Silva',
        sector: 'Public Sector',
        country: 'Spain',
        url: ''
      },
      {
        name: 'A. Amigos de Silva',
        sector: 'Public Sector',
        country: 'Spain',
        url: ''
      },
      {
        name: 'A. Amigos de Silva',
        sector: 'Public Sector',
        country: 'Spain',
        url: ''
      }
    ]
  end

  def partners
    partners = [
      {
        name: "Unicef",
        logo: "http://www.logospike.com/wp-content/uploads/2014/11/Unicef_logo-5.png"
      },
      {
        name: "International Trade Centre",
        logo: "http://empretecguyana.org/Images/ITC_logo.png"
      },
      {
        name: "Food and Agriculture Organization of the United Nations",
        logo: "http://www.fao.org/fileadmin/templates/faoweb/images/FAO-logo.png"
      },
    ]

    partners.map!{|p| OpenStruct.new(p)}
  end
end
