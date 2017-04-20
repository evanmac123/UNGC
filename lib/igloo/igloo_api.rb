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
        request.url url
        request.headers["Cookie"] = cookie
        request.body = body
      end

      response.body.tap do |value|
        ap value
      end
    end

  end
end
