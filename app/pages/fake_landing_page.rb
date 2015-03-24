class FakeLandingPage
  def hero
    {
      image: "//ungc.s3.amazonaws.com/hero/woman-farmer.jpg",
      theme: "dark",
      title: {
        title1: "The world is changing.",
        title2: "You need to keep pace."
      },
      blurb: "Sustainability is important to everyone&rsquo;s business. Companies that embrace sustainability best practices often outperform the market and are leading the modernization of business practices globally.",
      link: {
        label: "Learn More",
        url: "/redesign/participation/join"
      }
    }
  end

  def tiles
    [
      {
        color: "green",
        bg_image: "tiles/globe.jpg",
        title: "<br>What Does a UN Global Compact Commitment Mean?",
        link: {
          label: "Get Started",
          url: ""
        },
        double_width: true,
        double_height: true
      },
      {
        color: "light-blue",
        bg_image: "tiles/fibre.jpg",
        title: "<br><br>What You Can Do<br><br><br><br><br>",
        blurb: "Caring for the Climate<br>CEO Water Mandate<br>Women&rsquo;s Empowerment Principles<br>Children&rsquo;s Rights &amp; Business<br>Business for Peace",
        link: {
          label: "Find More",
          url: ""
        },
        double_width: true,
        double_height: true
      },
      {
        color: "light-blue",
        title: "<br>Why We Report.",
        bg_image: "tiles/book.jpg",
        blurb: "We ask our participants to complete an annual Communication on Progress (COP) report to ensure transparency and help others.",
        link: {
          label: "Find Your Local Network",
          url: ""
        },
        double_width: true
      },
      {
        color: "teal",
        title: "Listen.<br>Learn.<br>Collaborate.",
        link: {
          label: "Our Events",
          url: ""
        }
      },
      {
        color: "orange",
        title: "Who Else is Involved?",
        link: {
          label: "Browse",
          url: ""
        }
      }
    ]
  end
end
