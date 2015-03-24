class HomePage
  def initialize(container, payload_data)
    @container = container
    @data      = payload_data || {}
  end

  def hero
    @data[:hero] || {}
  end

  def tiles
    @data[:tiles] || []
  end

  def stats
    @data[:stats] || []
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
