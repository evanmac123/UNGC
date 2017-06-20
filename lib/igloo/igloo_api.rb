module Igloo
  class IglooApi

    def initialize(credentials)
      @credentials = credentials
    end

    def authenticate
      conn = Faraday.new("https://unglobalcompact.igloocommunities.com")
      url = "/.api/api.svc/session/create"

      params = @credentials.merge(apiversion: 1)

      response = conn.post(url, params)

      xml_response = response.body
      xml = Nokogiri::XML(xml_response)
      @session_key = xml.xpath("//xmlns:sessionKey").text
    end

    def find_user(guid)
      conn = Faraday.new("https://unglobalcompact.igloocommunities.com") do |f|
        f.use :cookie_jar
        f.adapter Faraday.default_adapter
      end

      cookie = "iglooauth=#{@session_key}"

      url = "/.api/api.svc/users/#{guid}/view"

      response = conn.get(url) do |request|
        request.headers = { "Cookie" => cookie }
      end

      response.body
    end

    def update_user(guid, bio)
      conn = Faraday.new("https://unglobalcompact.igloocommunities.com") do |f|
        f.use :cookie_jar
        f.adapter Faraday.default_adapter
      end

      cookie = "iglooauth=#{@session_key}"

      url = "/.api/api.svc/users/#{guid}/update"

      params = {
        igval_blog: "http://example.com/sam-blog"
      }

      body = params.map do |k,v|
        "#{k}=#{v}"
      end.join("&")

      response = conn.post do |request|
        request.url(url)
        request.headers["Cookie"] = cookie
        request.body = body
      end

      response.body
    end

    def stream_update_photo(contact)
      # TODO: implement me
      # Request URL:https://unglobalcompact.igloocommunities.com/.api/api.svc/account/profile/streamUpdatePhoto?_reqts=1493058171489&userId=1fb55da4-217d-478d-b087-0c869ad5f59a
      # Request Method:POST
      # userId: 1fbu5da4-217d-478d-b087-0c869ad5f59a
      # X-File-Name:big-toast-img.png
      # X-File-Size:250568
    end

    def bulk_upload(contacts)
      lines = []
      lines << BULK_UPLOAD_HEADERS.join(",")

      contacts.each do |contact|
        lines << to_csv_row(contact)
      end

      csvData = lines.join("\n")

      body = URI.encode_www_form(
        csvData: csvData,
        title: "UNGC Website Sync",
        type: "update",
        groupDelimiter: "|",
        spaceDelimiter: "~",
      )

      conn = Faraday.new("https://unglobalcompact.igloocommunities.com") do |f|
        f.use :cookie_jar
        f.adapter Faraday.default_adapter
      end

      cookie = "iglooauth=#{@session_key}"

      url = "/.api/api.svc/bulk_user_action/create_job"

      response = conn.post do |request|
        request.url(url)
        request.headers["Cookie"] = cookie
        request.body = body
      end

      response
    end

    # Pipe delimited list of Action Platform Spaces on igloo
    def active_groups_for(contact)
      # TODO: don't do the database work here
      # TODO: eliminate the n+1
      ActionPlatform::Subscription.active.for_contact(contact).
        includes(:platform).
        flat_map { |s| space_name(s.platform.name) }.
        join("|")
    end

    def inactive_groups_for(contact)
      # TODO: don't do the database work here
      # TODO: eliminate the n+1
      ActionPlatform::Subscription.inactive.for_contact(contact).
        includes(:platform).
        flat_map { |s| space_name(s.platform.name) }.
        join("|")
    end

    # Members are added to Igloo spaces by appending "~Space Members"
    # To the name of the group. This `space_name` translates the ActionPlatform name
    # in the database to match the Spaces in Igloo
    def space_name(platform_name)
      "#{SPACE_NAMES.fetch(platform_name)}~Space Members"
    end

    def to_csv_row(contact)
      attrs = {
        "firstname" => contact.first_name,
        "lastname" => contact.last_name,
        "email" => contact.email,
        "customIdentifier" => contact.id,
        "bio" => "",
        "birthdate" => nil,
        "gender" => nil,
        "address" => nil,
        "address2" => nil,
        "city" => nil,
        "state" => nil,
        "zipcode" => nil,
        "country" => contact.country.name,
        "cellphone" => nil,
        "fax" => nil,
        "busphone" => nil,
        "buswebsite" => nil,
        "company" => contact.organization.name,
        "department" => nil,
        "occupation" => contact.job_title,
        "sector" => contact.organization.sector.try!(:name), # TODO: convert from UNGC => Igloo
        "im_skype" => nil,
        "im_googletalk" => nil,
        "im_msn" => nil,
        "im_aol" => nil,
        "s_facebook" => nil,
        "s_linkedin" => nil,
        "s_twitter" => nil,
        "website" => nil,
        "blog" => nil,
        "associations" => nil,
        "hobbies" => nil,
        "interests" => nil,
        "skills" => nil,
        "isSAML" => nil,
        "managedByLdap" => nil,
        "s_google" => nil,
        "status" => nil,
        "extension" => nil,
        "i_report_to" => nil,
        "i_report_to_email" => nil,
        "im_skypeforbusiness" => nil,
        "groupsToAdd" => active_groups_for(contact),
        "groupsToRemove" => inactive_groups_for(contact),
      }

      attrs.values.join(",")
    end

    SPACE_NAMES = {
      "The Blueprint for SDG Leadership" => "Blueprint for SDG Leadership",
      "Reporting on the SDGs" => "Reporting on the SDGs",
      "Breakthrough Innovation" => "Breakthrough Innovation for the SDGs",
      "Financial Innovation for the SDGs" => "Financial Innovation for the SDGs",
      "Pathways to Low-Carbon & Resilient Development" => "Pathways to Low-Carbon & Resilient Development",
      "Health is Everyone's Business" => "Health is Everyone's Business",
      "Business for Inclusion" => "Business for Inclusion & Gender Equality",
      "Business Action for Humanitarian Needs" => "Business for Humanitarian Action and Peace",
      "Decent Work in Global Supply Chains" => "Decent Work in Global Supply Chains",
    }.freeze

    BULK_UPLOAD_HEADERS = [
      "firstname",
      "lastname",
      "email",
      "customIdentifier",
      "bio",
      "birthdate",
      "gender",
      "address",
      "address2",
      "city",
      "state",
      "zipcode",
      "country",
      "cellphone",
      "fax",
      "busphone",
      "buswebsite",
      "company",
      "department",
      "occupation",
      "sector",
      "im_skype",
      "im_googletalk",
      "im_msn",
      "im_aol",
      "s_facebook",
      "s_linkedin",
      "s_twitter",
      "website",
      "blog",
      "associations",
      "hobbies",
      "interests",
      "skills",
      "isSAML",
      "managedByLdap",
      "s_google",
      "status",
      "extension",
      "i_report_to",
      "i_report_to_email",
      "im_skypeforbusiness",
      "groupsToAdd",
      "groupsToRemove",
    ].freeze
  end
end
