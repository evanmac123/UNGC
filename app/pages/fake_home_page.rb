class FakeHomePage

  def hero
    {
      image: "//ungc.s3.amazonaws.com/hero/clean-room.jpg",
      theme: "dark",
      title: {
        title1: "We believe business",
        title2: "makes the difference."
      },
      blurb: "Sustainability is important to everyone&rsquo;s business. Companies that embrace sustainability best practices often outperform the market and are leading the modernization of business practices globally.",
      link: {
        label: "Learn More",
        url: ""
      },
      show_issues_nav: true
    }
  end

  def stats
     [
      {
        value: "8,000",
        label: "Active Companies"
      },
      {
        value: "200+",
        label: "Events Per Year"
      },
      {
        value: "160+",
        label: "Countries"
      }
    ]
  end

  def tiles
    [
      {
        color: "light-blue",
        bg_image: "tiles/seed.jpg",
        title: "<br><br>It&rsquo;s a simple<br>idea that is<br>spreading.",
        link: {
          url: "",
          label: "Get Started"
        },
        double_width: true,
        double_height: true
      },
      {
        color: "light-green",
        title: "What You Can Do",
        blurb: "Caring for the Climate<br>CEO Water Mandate<br>Women&rsquo;s Empowerment Principles<br>Children&rsquo;s Rights &amp; Business<br>Business for Peace",
        link: {
          url: "",
          label: "Find More"
        },
        double_height: true
      },
      {
        color: "teal",
        title: "Listen.<br>Learn.<br>Collaborate.",
        link: {
          url: "",
          label: "Our Events"
        }
      },
      {
        color: "green",
        bg_image: "tiles/world-map.png",
        title: "<br>Think Globally.<br>Act Locally.",
        link: {
          url: "",
          label: "Find Your Local Network"
        },
        double_width: true
      },
      {
        color: "orange",
        title: "Who Else is Involved?",
        link: {
          url: "",
          label: "Browse"
        }
      },
      {
        color: "pastel-blue",
        title: "<img src='//ungc.s3.amazonaws.com/tiles/chat-bubbles.png'><br>It&rsquo;s a big job.",
        link: {
          url: "",
          label: "Find Partners"
        },
        double_width: true
      }
    ]
  end

  def events
    {
      featured: {
        url: "",
        title: "6th Annual Women&rsquo;s Empowerment Principles Event: Gender Equality and the Global Jobs Challenge",
        date: "12 December 2014",
        location: "New York, NY, USA",
        excerpt: "Spotlights business strategies, experience, and challenges on increasing and enhancing job opportunities for women and expanding access to decent jobs.",
        thumbnail: "//ungc.s3.amazonaws.com/womens-empowerment.jpg"
      },
      secondary: [
        {
          url: "",
          title: "CEO Water Mandate Multi-Stakeholder Working Conference",
          date: "8&hairsp;&ndash;&hairsp;10 April 2015",
          location: "Lima, Peru"
        },
        {
          url: "",
          title: "Annual Conference&hairsp;&mdash;&hairsp;Children&rsquo;s Rights and Business Principles",
          date: "12 May 2015",
          location: "Nairobi, Kenya"
        },
        {
          url: "",
          title: "CEO Water Mandate Multi-Stakeholder Working Conference",
          date: "24&hairsp;&ndash;&hairsp;26 June 2015",
          location: "Jakarta, Indonesia"
        }
      ],
      local: [
        {
          url: "",
          title: "Regional Meeting Africa/MENA",
          date: "20&hairsp;&ndash;&hairsp;21 February 2015",
          location: "Accra, Ghana"
        },
        {
          url: "",
          title: "Regional Meeting Asia/Oceania",
          date: "24&hairsp;&ndash;&hairsp;26 February 2015",
          location: "Jakarta, Indonesia"
        }
      ]
    }
  end
end
