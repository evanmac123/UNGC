class FakeHighlightPage
  def hero
    {
      image: "//ungc.s3.amazonaws.com/hero/georg-kell.jpg",
      theme: "dark",
      title: {
        title1: "UN Global Compact &ndash;",
        title2: "15 Years of Sustainability Success"
      },
      show_section_nav: true
    }
  end

  def article_blocks
    [
      {
        title: "Why Join UN Global Compact",
        content: "<p>The United Nations Global Compact challenged the business community to be a positive force for sustainable change. Business is uniquely positioned to create a more sustainable world since it touches every level of society.</p><p>We work with businesses in the areas of human rights, labour, environment, anti-corruption and society to transform our world. We&rsquo;re shaping a better, sustainable future. Join us and be part of it!</p>",
        sidebar_widgets: [
          {
            type: "image",
            src: "//ungc.s3.amazonaws.com/sidebar/2.jpg",
            alt: ""
          }
        ]
      },
      {
        title: "Everyone Benefits from a Better World",
        align: "center",
        bg_image: "//ungc.s3.amazonaws.com/hero/earth-at-night.jpg",
        theme: "dark",
        content: "<p>Strong markets and strong societies go hand in hand. Even the most principled companies are challenged to thrive in communities marked by instability, to find skilled labour where adequate education is lacking, or to withstand disasters stemming from climate change. With the United Nations expected to launch a ground-breaking set of global sustainable development goals in 2015, business will have a newly relevant framework to guide their efforts towards society&hairsp;&mdash;&hairsp;representing a huge opportunity to drive sustainable business.</p><br><p><a href='' class='button light-green'>See how you can drive change</a></p>"
      },
      {
        title: "You Can Make a Difference",
        content: "<p>Global Compact participants are changing the world. They are leading the way with innovative solutions to address poverty, health, equality, education, environmental sustainability, food and peace. You can be part of it.</p><p>Over 8,000 companies and 4,000 non-business participants have already made the commitment to adopt more sustainable business practices. Sustainability is not just good for business; it&rsquo;s good for economies and societies everywhere.</p><p><a href='' class='button light-blue'>Join UN Global Compact now</a></p>",
        sidebar_widgets: [
          {
            type: "image",
            src: "//ungc.s3.amazonaws.com/sidebar/4.jpg",
            alt: ""
          }
        ]
      }
    ]
  end
end
