class FakeLongArticlePage
  def hero
    {
      title: [
        "Article page headline",
        "goes here."
      ]
    }
  end

  def article_blocks
    [
      {
        title: "Harum Quo Ut Et Aut Explicabo Debitis Magni Possimus Dolore Illo Consequatur",
        content: "<p>At minus excepturi nostrum ut cupiditate expedita enim repellat necessitatibus cumque ad sint pariatur. et quo fuga saepe recusandae quasi. dolorem odit assumenda aspernatur ea qui ratione possimus quis quis reprehenderit. dolorem qui amet cum doloremque sed occaecati ut. non quia iusto provident. asperiores quae ut quod culpa quibusdam rerum</p><p>Accusamus nihil magni nihil sint odio eligendi fugiat id officia quia deleniti nesciunt. fugit nulla aut quo harum perferendis iusto impedit perferendis architecto perferendis iusto sint animi. repudiandae itaque omnis ratione ex ut ipsum architecto aut vel ab accusantium inventore odio ea</p><h2>Consequuntur Molestias Doloribus Quibusdam Quia Rerum Facilis Fuga Vitae</h2><p>Perferendis nulla temporibus eum sit commodi inventore consequatur reiciendis voluptas explicabo enim facere. quia omnis magnam dolores officia vel mollitia error pariatur. itaque dolorem vel sit accusamus ratione ratione vel autem exercitationem qui ipsum exercitationem ipsam molestiae. nulla molestias error et qui excepturi itaque at deserunt modi nobis cum delectus. ratione nihil quae harum</p><ul><li><strong>Laudantium</strong> - Quis sunt voluptates id beatae</li><li><strong>Exercitationem</strong> - Quod ipsum quasi animi nemo porro et autem veniam</li><li><strong>Aspernatur</strong> - Natus aspernatur officiis odit sed eos vel repellendus</li></ul><p>Sit consequuntur nihil dicta laudantium et quos est dignissimos autem nesciunt reprehenderit fugiat. suscipit et labore cum eaque inventore sunt quia magni molestiae. est laboriosam consequuntur quia veniam enim enim. quis velit illo enim ut aut porro voluptatem consequatur voluptate quia. eius aliquam et commodi nam veritatis ut sint nulla voluptas eos quae nihil est sit</p><ol><li><strong>Corrupti</strong> - Consequatur facilis ducimus dolores illo itaque dolorem voluptatibus exercitationem ea cupiditate distinctio</li><li><strong>Quas</strong> - Quasi molestiae molestiae vitae doloribus praesentium et tenetur voluptates nulla est consequatur</li><li><strong>Est</strong> - Illum et quos cumque soluta omnis voluptatibus officiis tenetur</li></ol><h3>Reprehenderit Dicta Occaecati Esse Qui Earum Qui Asperiores</h3><p>Odio et laborum magni nemo. ut et quis provident sed. aperiam laboriosam et vero et nihil praesentium libero qui rem voluptatem. repudiandae et asperiores veritatis. qui laudantium ut voluptas quia qui rerum est laboriosam sed. nesciunt porro distinctio ad blanditiis dolorum alias quia</p><p>Dignissimos fuga numquam sint nobis est dolore. aliquam architecto ut vero. pariatur eius omnis eligendi at nostrum consequatur corrupti consequuntur et eos incidunt ex labore repellendus. ratione quia maiores necessitatibus quis veritatis sequi est eveniet qui est saepe voluptas dolorum. quos earum officiis et aut quibusdam</p>",
        sidebar_widgets: [
          {
            type: "contact",
            photo: "people/walid-nagi.jpg",
            name: "Mr. Walid Nagi",
            title: "Head Local Networks",
            email: "nagi@un.org",
            phone: "+1-212-907-1331"
          },
          {
            type: "button",
            label: "Newsletter Signup",
            url: ""
          },
          {
            type: "links",
            title: "More About",
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
          }
        ]
      }
    ]
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
    {
      featured: {
        url: "",
        title: "6th Annual Women's Empowerment Principles Event: Gender Equality and the Global Jobs Challenge",
        date: "12 December 2014",
        location: "New York, NY, USA",
        excerpt: "Spotlights business strategies, experience, and challenges on increasing and enhancing job opportunities for women and expanding access to decent jobs.",
        thumbnail: "/assets/images/womens-empowerment.jpg"
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
