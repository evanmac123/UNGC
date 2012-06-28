# ./script/runner 'InsertLocalNetworkPages.new.run' -e production

class InsertLocalNetworkPages
  def run

    pages =
     {  path: "/NetworksAroundTheWorld/formal_networks.html",
         title: "Formal Networks",
         content: "<h1>Formal Networks</h1><%= render :partial => 'shared/local_network_listing', :locals => {:state => :formal} %>",
         parent_id: 4832,
         position: 1,
         display_in_navigation: true,
         approved_at: Time.now,
         dynamic_content: true,
         version_number: 1,
         group_id: 16,
         approval: "approved" },
     {  path: "/NetworksAroundTheWorld/established_networks.html",
        title: "Established Networks",
        content: "<h1>Established Networks</h1><%= render :partial => 'shared/local_network_listing', :locals => {:state => :established} %>",
        parent_id: 4832,
        position: 2,
        display_in_navigation: true,
        approved_at: Time.now,
        dynamic_content: true,
        version_number: 1,
        group_id: 16,
        approval: "approved" },
     {
        path: "/NetworksAroundTheWorld/emerging_networks.html",
        title: "Emerging Networks",
        content: "<h1>Emerging Networks</h1><%= render :partial => 'shared/local_network_listing', :locals => {:state => :emerging} %>",
        parent_id: 4832,
        position: 3,
        display_in_navigation: true,
        approved_at: Time.now,
        dynamic_content: true,
        version_number: 1,
        group_id: 16,
        approval: "approved" }

    pages.each do |page|
      puts page
      Page.create(page)
    end

  end
end