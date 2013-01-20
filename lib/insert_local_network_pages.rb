# ./script/runner 'InsertLocalNetworkPages.new.run' -e production

class InsertLocalNetworkPages
  def run

    # Create Local Network Dashboard accessible pages

    conditions = { :name                  => 'Local Network Resources',
                   :display_in_navigation => false,
                   :html_code             => 'networks',
                   :position              => 3,
                   :path_stub             => 'LocalNetworks' }

    page_group = PageGroup.find(:first, :conditions => conditions) || PageGroup.create(conditions)

    pages =  { path: "/LocalNetworks/resources.html",
               title: "Resources",
               content: "<h1>Resources</h1><p>Easy access to tools, resources and guidance material from the Global Compact Office.</p>",
               position: 1,
               display_in_navigation: true,
               approved_at: Time.now,
               dynamic_content: true,
               version_number: 1,
               group_id: page_group.id,
               approval: "approved" },

             {  path: "/LocalNetworks/newsletter_archive.html",
                title: "Newsletter Archive",
                content: "<h1>Newsletter Archive</h1><p>Past issues of Local Networks newsletters.</p>",
                position: 2,
                display_in_navigation: true,
                approved_at: Time.now,
                dynamic_content: true,
                version_number: 1,
                group_id: page_group.id,
                approval: "approved" },

             {  path: "/LocalNetworks/presentations.html",
                title: "Presentations",
                content: "<h1>Presentations</h1>Past presentations from Global Compact Events",
                position: 3,
                display_in_navigation: true,
                approved_at: Time.now,
                dynamic_content: true,
                version_number: 1,
                group_id: page_group.id,
                approval: "approved" }

    pages.each do |page|
      puts page
      Page.create(page)
    end

  end
end