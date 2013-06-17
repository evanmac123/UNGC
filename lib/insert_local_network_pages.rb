# rails runner 'InsertLocalNetworkPages.new.run' -e production

class InsertLocalNetworkPages
  def run

    # reorder page groups for inserting the group in position 3
    PageGroup.all.each {|p| p.update_attribute :position, (p.position + 1) if p.position > 2}

    # Create Local Network Dashboard accessible pages
    conditions = { :name                  => 'Local Network Resources',
                   :display_in_navigation => false,
                   :html_code             => 'networks_rsrc',
                   :position              => 3,
                   :path_stub             => 'LocalNetworksResources' }

    page_group = PageGroup.find(:first, :conditions => conditions) || PageGroup.create(conditions)

    pages = {  path: "/LocalNetworksResources/training_guidance_material/index.html",
               title: "Training and Guidance Material",
               content: "<h1>Training and Guidance Material</h1><p>Easy access to tools, resources and guidance material from the Global Compact Office.</p>",
               position: 1,
               display_in_navigation: true,
               approved_at: Time.now,
               dynamic_content: false,
               version_number: 1,
               group_id: page_group.id,
               approval: "approved" },

             {  path: "/LocalNetworksResources/news_updates/index.html",
                title: "News and Updates",
                content: "<h1>News and Updates</h1><p>Past issues of Local Networks newsletters.</p>",
                position: 2,
                display_in_navigation: true,
                approved_at: Time.now,
                dynamic_content: false,
                version_number: 1,
                group_id: page_group.id,
                approval: "approved" },

             {  path: "/LocalNetworksResources/reports/index.html",
                title: "Reports",
                content: "<h1>Reports</h1>Reports from the Global Compact",
                position: 3,
                display_in_navigation: true,
                approved_at: Time.now,
                dynamic_content: false,
                version_number: 1,
                group_id: page_group.id,
                approval: "approved" }
    pages.each { |page| Page.create(page) }

    # insert subpages under the main sections

    page = Page.find(:first, :conditions => {:path => '/LocalNetworksResources/training_guidance_material/index.html'})
    pages =  { path: "/LocalNetworksResources/training_guidance_material/outreach.html",
               title: "Outreach",
               content: "<h1>Outreach</h1><p>Reaching out to participants and stakeholders.</p>",
               position: 1,
               display_in_navigation: true,
               approved_at: Time.now,
               dynamic_content: false,
               version_number: 1,
               parent_id: page.id,
               group_id: page_group.id,
               approval: "approved" },

             {  path: "/LocalNetworksResources/training_guidance_material/cop_training.html",
                title: "COP Training",
                content: "<h1>COP Training</h1><p>Information regarding Communication on Progress training.</p>",
                position: 2,
                display_in_navigation: true,
                approved_at: Time.now,
                dynamic_content: false,
                version_number: 1,
                parent_id: page.id,
                group_id: page_group.id,
                approval: "approved" },

             {  path: "/LocalNetworksResources/training_guidance_material/webinars.html",
                title: "Webinars",
                content: "<h1>Webinars</h1><p>Webinars for Local Networks</p>",
                position: 3,
                display_in_navigation: true,
                approved_at: Time.now,
                dynamic_content: false,
                version_number: 1,
                parent_id: page.id,
                group_id: page_group.id,
                approval: "approved" },

              {  path: "/LocalNetworksResources/training_guidance_material/issue_specific_guidance.html",
                 title: "Issue-Specific Guidance",
                 content: "<h1>Issue-Specific Guidance</h1><p>Human Rights, Labour, Environment, Anti-Corruption</p>",
                 position: 4,
                 display_in_navigation: true,
                 approved_at: Time.now,
                 dynamic_content: false,
                 version_number: 1,
                 parent_id: page.id,
                 group_id: page_group.id,
                 approval: "approved" },

               {  path: "/LocalNetworksResources/training_guidance_material/partnerships.html",
                  title: "Partnerships",
                  content: "<h1>Partnerships</h1><p>Partnerships for Local Networks.</p>",
                  position: 5,
                  display_in_navigation: true,
                  approved_at: Time.now,
                  dynamic_content: false,
                  version_number: 1,
                  parent_id: page.id,
                  group_id: page_group.id,
                  approval: "approved" }
    pages.each { |page| Page.create(page) }

    page = Page.find(:first, :conditions => {:path => "/LocalNetworksResources/reports/index.html"})
    pages =  { path: "/LocalNetworksResources/reports/foundation_financial_statements.html",
               title: "Foundation for the Global Compact",
               content: "<h1>Foundation for the Global Compact</h1><p>Foundation Reports</p>",
               position: 1,
               display_in_navigation: true,
               approved_at: Time.now,
               dynamic_content: false,
               version_number: 1,
               parent_id: page.id,
               group_id: page_group.id,
               approval: "approved" }
    Page.create(pages)

  end
end