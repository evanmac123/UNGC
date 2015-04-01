class ArticlePage
  def initialize(container, payload_data)
    @container = container
    @data      = payload_data || {}
  end

  def hero
    @data[:hero] || {}
  end

  def article_block
    @data[:article_block] || {}
  end

  def contact_widget
    @data[:contact_widget] || {}
    # {
    #   type: "contact",
    #   photo: "//ungc.s3.amazonaws.com/people/walid-nagi.jpg",
    #   name: "Mr. Walid Nagi",
    #   title: "Head Local Networks",
    #   email: "nagi@un.org",
    #   phone: "+1-212-907-1331"
    # }
  end

  def call_to_action
    @data[:call_to_action] || {}
  end

  def links_block
    @data[:links_block] || {}
  end

  def resources
    [
      {
        id: 1151,
        type: "document",
        tag: "Case Study",
        title: "Guide to Corporate Sustainability",
        url: ""
      },
      {
        id: 1131,
        type: "document",
        tag: "Case Study",
        title: "Joining Forces: Collaboration and Leadership for Sustainability",
        url: ""
      },
      {
        id: 1181,
        type: "document",
        tag: "Case Study",
        title: "Private Sector Investment and Sustainable Development",
        url: ""
      }
    ]
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
end

