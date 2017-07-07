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

    def bulk_upload(csv)
      return if csv.blank?

      body = URI.encode_www_form(
        csvData: csv,
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

      if response.success?
        response
      else
        path = "./tmp/failed-igloo-sync.csv"
        File.open(path, "w") do |f|
          f.write(csv)
        end
        raise response.body.to_s
        puts "the failed csv can be found here: #{path}"
      end
    end

  end
end
