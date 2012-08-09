# ./script/runner 'InsertLocalNetworkPages.new.run' -e production

class InsertLocalNetworkPages
  def run

    parent = Page.find_by_path_and_approval '/NetworksAroundTheWorld/index.html','approved'

    pages =
    {  path: "/NetworksAroundTheWorld/network_categories.html",
       title: "Network Categories",
       content: "<h1> Network Categories</h1> <h2> Formal Networks</h2> <p> Formal Networks meet all governance and accountability requirements laid out in the Memorandum of Understanding (MoU). The MoU between the Local Network and the Global Compact Office has been formally signed, and use of the Network logo is authorized.</p> <h2> Established Networks</h2> <p> Established Networks have met at least two of the governance and accountability requirements, but have not formally signed the MoU.</p> <h2> Emerging Networks</h2> <p> Emerging Networks are in the early stages of development: they have identified an individual to liaise with the Global Compact Office with regard to nationally organized awareness and outreach activities, but have not met at least two of the MoU requirements.</p> <h2> What is the MoU?</h2> <p> The MoU is an annual agreement signed between the Local Network and the Global Compact Office to confirm the authorization to use the Global Compact Network logo in connection with the Network's activities. The MoU lays out the minimum requirements of Global Compact Local Networks including their governance and accountability requirements. Annual reconfirmation is based on the understanding that the Global Compact Local Network will continue to commit to engage in activities that are consistent with the purpose and objectives of the Global Compact.</p>",
       parent_id: parent.id,
       position: 1,
       display_in_navigation: true,
       approved_at: Time.now,
       dynamic_content: true,
       version_number: 1,
       group_id: 16,
       approval: "approved" },

     {  path: "/NetworksAroundTheWorld/formal_networks.html",
        title: "Formal Networks",
        content: "<h1>Formal Networks</h1><%= render :partial => 'shared/local_network_listing', :locals => {:state => :formal} %>",
        parent_id: parent.id,
        position: 2,
        display_in_navigation: true,
        approved_at: Time.now,
        dynamic_content: true,
        version_number: 1,
        group_id: 16,
        approval: "approved" },

     {  path: "/NetworksAroundTheWorld/established_networks.html",
        title: "Established Networks",
        content: "<h1>Established Networks</h1><%= render :partial => 'shared/local_network_listing', :locals => {:state => :established} %>",
        parent_id: parent.id,
        position: 3,
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
        parent_id: parent.id,
        position: 4,
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