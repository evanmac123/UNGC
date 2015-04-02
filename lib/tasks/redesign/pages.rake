namespace :redesign do

  desc "create the basic site map"
  task :tree do
    walk PAGES do |page, depth|
      title = page[:title]
      layout = page[:layout]
      indent = depth.times.map{"\t"}.join
      puts "#{indent}#{title} (#{layout})"
    end
  end

  desc "create the basic site map"
  task :tree2 do
    root = Node.new
    root.children = tree(PAGES, root)
    ap root
  end

  desc "show the unique layouts"
  task :layouts do
    layouts = walk PAGES do |page, depth|
      page[:layout]
    end
    puts layouts.flatten.uniq
  end

  desc "show slug paths"
  task :slugs do
    stack = []
    last_depth = 0
    last_layout = nil
    walk PAGES do |page, depth|
      case
      when depth > last_depth
        stack << last_layout
      when depth < last_depth
        stack.pop
      end
      last_layout = page[:title].downcase.gsub(' ', '_').underscore
      last_depth = depth

      puts stack.join ","
    end
  end

  private

  def walk(pages, depth = 0, &block)
    pages.map do |page|
      value = block.call(page, depth)
      child_values = if page.has_key? :children
        walk page[:children], depth+1, &block
      else
        []
      end
      [value, child_values]
    end
  end

  def tree(pages, parent_node)
    pages.map do |page|
      node = Node.new
      node.title = page[:title]
      node.depth = parent_node.depth + 1
      node.parent = parent_node
      if page.has_key? :children
        node.children = tree(page[:children], node)
      end
      node
    end
  end

  class Node
    attr_accessor :title, :depth, :parent, :children

    def initialize
      @title = ""
      @depth = 0
      @children = []
    end

  end

  PAGES = [
      {
        title: "UN Global Compact Home",
        layout: :home,
        children: [
          {
            title: "What is UN Global Compact?",
            layout: :landing,
            children: [
              {
                title: "Our Mission",
                layout: :highlight,
                children: [
                  {
                    title: "Ten Principles",
                    layout: :article,
                  },
                  {
                    title: "Individual Principle Pages",
                    layout: :article,
                  },
                ]
              },
              {
                title: "Our Strategy",
                layout: :highlight,
                children: [
                  {
                    title: "Sustainable Development Goals",
                    layout: :article,
                  },
                ]
              },
              {
                title: "Our Commitment to You",
                layout: :highlight,
              },
              {
                title: "Who’s Involved",
                layout: :highlight,
                children: [
                   {
                    title: "Participant Directory",
                    layout: :directory,
                  },
                  {
                    title: "Participant Profiles",
                    layout: :company_profile,
                  },
                ]
              },
              {
                title: "Our Focus",
                layout: :landing,
                children: [
                  {
                    title: "Environment",
                    layout: :issue,
                  },
                  {
                    title: "Social",
                    layout: :issue,
                  },
                  {
                    title: "Government",
                    layout: :issue,
                  },
                  {
                    title: "All Issues",
                    layout: :tile_grid,
                  },
                ]
              },
              {
                title: "Social",
                layout: :issue,
                children: [
                  {
                    title: "Human Rights",
                    layout: :issue,
                  },
                  {
                    title: "People with Disabilities",
                    layout: :issue,
                  },
                  {
                    title: "Children’s Rights",
                    layout: :issue,
                  },
                  {
                    title: "Gender Equality",
                    layout: :issue,
                  },
                  {
                    title: "Women’s Empowerment",
                    layout: :issue,
                  },
                  {
                    title: "Child Labour",
                    layout: :issue,
                  },
                  {
                    title: "Indigenous Peoples",
                    layout: :issue,
                  },
                  {
                    title: "Health",
                    layout: :issue,
                  },
                  {
                    title: "Indigenous Peoples",
                    layout: :issue,
                  },
                  {
                    title: "Migrant Workers",
                    layout: :issue,
                  },
                  {
                    title: "Forced Labour",
                    layout: :issue,
                  },
                  {
                    title: "Human Trafficking",
                    layout: :issue,
                  },
                  {
                    title: "Poverty",
                    layout: :issue,
                  },
                  {
                    title: "Education",
                    layout: :issue,
                  },
                ]
              },

              {
                title: "Environment",
                layout: :issue,
                children: [
                  {
                    title: "Biodiversity",
                    layout: :issue,
                  },
                  {
                    title: "Climate Change",
                    layout: :issue,
                  },
                  {
                    title: "Water",
                    layout: :issue,
                  },
                  {
                    title: "Energy",
                    layout: :issue,
                  },
                  {
                    title: "Food & Agriculture",
                    layout: :issue,
                  },
                ]
              },
              {
                title: "Governance",
                layout: :issue,
                children: [
                  {
                    title: "Anti-Corruption",
                    layout: :issue,
                  },
                  {
                    title: "Peace",
                    layout: :issue,
                  },
                  {
                    title: "Rule of Law",
                    layout: :issue,
                  },
                ]
              },
            ]
          },
          {
            title: "Participation",
            layout: :landing,
            children: [
              {
                title: "How to Engage",
                layout: :landing,
                children: [
                  {
                    title: "Business",
                    layout: :article,
                  },
                  {
                    title: "Cities",
                    layout: :article,
                  },
                  {
                    title: "NGOs",
                    layout: :article,
                  },
                  {
                    title: "Academic",
                    layout: :article,
                  },
                  {
                    title: "Governments",
                    layout: :article,
                  },
                  {
                    title: "Trade Associations",
                    layout: :article,
                  },
                ]
              },
              {
                title: "Why Join",
                layout: :highlight,
                children: [
                  {
                    title: "Who Can Join",
                    layout: :article,
                  },
                  {
                    title: "What’s the Commitment Mean?",
                    layout: :highlight,
                  },
                  {
                    title: "See How Others Benefit",
                    layout: :article,
                  },
                  {
                    title: "Application Process",
                    layout: :article,
                  },
                  {
                    title: "Business",
                    layout: :article_form,
                  },
                  {
                    title: "Non-Business",
                    layout: :article_form,
                  },
                ]
              },
              {
                title: "Report",
                layout: :highlight,
                children: [
                  {
                    title: "COP",
                    layout: :article,
                  },
                  {
                    title: "COE",
                    layout: :article,
                  },
                  {
                    title: "Prepare Your Report",
                    layout: :article,
                  },
                  {
                    title: "Submit Your Report",
                    layout: :article_form,
                  },
                ]
              },
              {
                title: "Guidance for UN Global Compact Participants",
                layout: :landing,
                children: [
                  {
                    title: "Guide for Newcomers",
                    layout: :highlight,
                  },
                  {
                    title: "Resources to Get You Started",
                    layout: :list,
                  },
                  {
                    title: "Brand / Logo Guidelines",
                    layout: :article,
                  },
                  {
                    title: "UN Policies",
                    layout: :article,
                  },
                  {
                    title: "Welcome Materials",
                    layout: :list,
                  },
                  {
                    title: "Intro to RM",
                    layout: :article,
                  },
                ]
              },
            ]
          },
          {
            title: "Take Action",
            layout: :landing,
            children: [
              {
                title: "Take Action",
                layout: :landing
              },
              {
                title: "Leadership",
                layout: :landing,
                children: [
                  {
                    title: "Global Compact Lead",
                    layout: :article
                  },
                  {
                    title: "Membership Fees & Details",
                    layout: :article
                  },
                  {
                    title: "Apply",
                    layout: :article_form
                  },
                  {
                    title: "Events & Meetings",
                    layout: :article
                  },
                ]
              },

              {
                title: "Partnerships",
                layout: :highlight,
                children: [
                  {
                    title: "UN-Business Partnerships",
                    layout: :article
                  },
                  {
                    title: "Social Enterprise",
                    layout: :article
                  }
                ]
              },
              {
                title: "Find Events",
                layout: :event,
                children: [
                  {
                    title: "Sponsorships",
                    layout: :article
                  },
                  {
                    title: "Yearly Events",
                    layout: :article
                  },
                ]
              },
              {
                title: "Individual Events",
                layout: :event_detail,
                children: [
                  {
                    title: "Overview / Agenda",
                    layout: :article
                  },
                  {
                    title: "Schedule",
                    layout: :article
                  },
                  {
                    title: "Speakers",
                    layout: :article
                  },
                  {
                    title: "Attendees",
                    layout: :article
                  },
                  {
                    title: "Meetings Documents",
                    layout: :article
                  },
                  {
                    title: "Sponsorships",
                    layout: :article
                  },
                ]
              },
              {
                title: "What You Can Do",
                layout: :tile_grid,
                children: [
                  {
                    title: "Business for Peace",
                    layout: :action_detail
                  },
                  {
                    title: "Caring for Climate",
                    layout: :action_detail
                  },
                  {
                    title: "CEO Water Mandate",
                    layout: :action_detail
                  },
                  {
                    title: "Child Labour Platform",
                    layout: :action_detail
                  },
                  {
                    title: "Children’s Rights & Business Principles",
                    layout: :action_detail
                  },
                  {
                    title: "Food & Agriculture Business Principles",
                    layout: :action_detail
                  },
                  {
                    title: "Women’s Empowerment Principles",
                    layout: :action_detail
                  },
                  {
                    title: "Financial Markets",
                    layout: :article
                  },
                  {
                    title: "Leadership",
                    layout: :article
                  },
                  {
                    title: "Management",
                    layout: :action_detail
                  },
                  {
                    title: "Management & Education",
                    layout: :action_detail
                  },
                  {
                    title: "Supply Chain Sustainability",
                    layout: :action_detail
                  },
                  {
                    title: "UN Goals & Issues",
                    layout: :article
                  }
                ]
              },
            ]
          },
          {
            title: "Engage Locally",
            layout: :engage_locally,
            children: [
              {
                title: "Regions",
                layout: :regions,
                children: [
                  {
                    title: "Africa",
                    layout: :ln_profile
                  },
                  {
                    title: "Asia",
                    layout: :ln_profile
                  },
                  {
                    title: "Europe",
                    layout: :ln_profile
                  },
                  {
                    title: "Latin America & Caribbean",
                    layout: :ln_profile
                  },
                  {
                    title: "MENA",
                    layout: :ln_profile
                  },
                  {
                    title: "North America",
                    layout: :ln_profile
                  },
                  {
                    title: "Oceana",
                    layout: :ln_profile
                  },
                ]
              },
              {
                title: "About Local Networks",
                layout: :highlight
              },
              {
                title: "Manage Your Local Network",
                layout: :landing,
                children: [
                  {
                    title: "Engagement Framework",
                    layout: :highlight,
                    children: [
                      {
                        title: "Human Rights & Labour",
                        layout: :article
                      },
                      {
                        title: "Children’s Rights & Business Principles",
                        layout: :article
                      },
                      {
                        title: "Caring for Climate",
                        layout: :article
                      },
                      {
                        title: "CEO Water Mandate",
                        layout: :article
                      },
                      {
                        title: "Anti-Corruption",
                        layout: :article
                      },
                      {
                        title: "Business for Peace",
                        layout: :article
                      },
                      {
                        title: "Supply Chain Sustainability",
                        layout: :article
                      },
                    ]
                  },
                ]
              },
              {
                title: "News & Updates",
                layout: :article
              },
              {
                title: "Training & Guidance Materials",
                layout: :highlight,
                children: [
                  {
                    title: "Outreach",
                    layout: :article
                  },
                  {
                    title: "COP Training",
                    layout: :article
                  },
                  {
                    title: "Webinars",
                    layout: :tile_grid_or_list
                  },
                  {
                    title: "Partnerships",
                    layout: :article
                  },
                  {
                    title: "Fundraising Toolkits",
                    layout: :list
                  },
                ]
              },
              {
                title: "Reports",
                layout: :highlight,
                children: [
                  {
                    title: "Foundation for the Global Compact",
                    layout: :article,
                  },
                  {
                    title: "Meetings Outcome Documents",
                    layout: :list,
                  },
                  {
                    title: "Local Network Annual Reports",
                    layout: :list,
                  },
                  {
                    title: "UN Global Compact Activity Reports",
                    layout: :list,
                  },
                  {
                    title: "Local Network Advisory Group Documents",
                    layout: :list,
                  },
                ]
              },
            ]
          },
          {
            title: "Explore Our Library",
            layout: :library,
            children: [
              {
                title: "Explore Our Library",
                layout: :library
              },
              {
                title: "Meeting Reports",
                layout: :library_resource
              },
              {
                title: "Global Compact Reports",
                layout: :library_resource
              },
              {
                title: "Guidance",
                layout: :library_resource
              },
              {
                title: "Case Studies",
                layout: :library_resource
              },
              {
                title: "Newsletters",
                layout: :library_resource
              },
              {
                title: "Training",
                layout: :library_resource
              },
              {
                title: "Presentations",
                layout: :library_resource
              },
              {
                title: "Webinars",
                layout: :library_resource
              },
              {
                title: "Data Visualization / Infographics",
                layout: :library_resource
              },
              {
                title: "Academic Literature",
                layout: :library_resource
              },
              {
                title: "External Links",
                layout: :library_resource
              },
              {
                title: "Toolkits",
                layout: :library_resource
              },
              {
                title: "Links",
                layout: :library_unsure
              },
            ]
          },
          {
            title: "Secondary/Tertiary Navigation",
            layout: :i_don_know,
          },
          {
            title: "About",
            layout: :landing,
            children: [
              {
                title: "Board",
                layout: :list,
              },
              {
                title: "Governance",
                layout: :article,
              },
              {
                title: "How We are Financed",
                layout: :article,
              },
              {
                title: "Government Support",
                layout: :article,
              },
              {
                title: "UN Activities",
                layout: :article,
              },
              {
                title: "Jobs & Internships",
                layout: :list,
              },
              {
                title: "Contact Us (Form)",
                layout: :article_form,
              },
            ]
          },
          {
            title: "News",
            layout: :news,
            children: [
              {
                title: "Press Releases",
                layout: :pr_list,
              },
              {
                title: "Individual Press Releases",
                layout: :article,
              },
              {
                title: "In The Media",
                layout: :tile_grid_or_list,
              },
              {
                title: "Speeches",
                layout: :tile_grid_or_list,
              },
              {
                title: "Newsletters",
                layout: :tile_grid_or_list,
              },
            ]
          },
          {
            title: "Search",
            layout: :search,
          },
          {
            title: "Languages",
            layout: :article_unsure,
          },
          {
            title: "Login",
            layout: :article_form,
          },
          {
            title: "Footer",
            layout: :footer,
            children: [
              {
                title: "UN Links",
                layout: :hmmm
              },
              {
                title: "Copyright",
                layout: :hmmm
              },
              {
                title: "Privacy Policy",
                layout: :hmmm
              },
              {
                title: "Contact Us(Form)",
                layout: :hmmm
              },
              {
                title: "Contribute",
                layout: :hmmm
              },
              {
                title: "Quick Links",
                layout: :hmmm
              },
              {
                title: "Follow Us (Social Media)",
                layout: :hmmm
              },
              {
                title: "Twitter Feed",
                layout: :hmmm
              },
            ]
          }
        ]
      },
    ]

end
