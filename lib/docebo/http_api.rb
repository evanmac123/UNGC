module Docebo
  class HttpApi

    DATE_FORMAT = "%Y-%m-%d"

    attr_reader :access_token, :refresh_token

    def self.create
      config = Rails.application.secrets.docebo&.symbolize_keys
      if config.blank?
        raise "config/secrets.yml is missing docebo settings. See config/secrets.yml.example for details"
      end

      new(**config)
    end

    def initialize(conn: nil, url:, client_id:, client_secret:, username:, password:, log: false)
      @url = url
      @conn = conn || Faraday.new(url: url) do |faraday|
        faraday.response :logger if log
        faraday.adapter Faraday.default_adapter
      end
      @client_id = client_id
      @client_secret = client_secret
      @username = username
      @password = password
    end

    def authenticate
      body = {
        "grant_type" => "password",
        "client_id" => @client_id,
        "client_secret" => @client_secret,
        "scope" => "api",
        "username" => @username,
        "password" => @password,
      }

      response = post("/oauth2/token", body: body)
      @access_token = response.fetch("access_token")
      @refresh_token = response.fetch("refresh_token")
      @access_token
    end

    def list_users
      Array(get("/manage/v1/user").dig("data", "items"))
    end

    def list_courses(cursor: nil, page: nil)
      body = {}
      body[:cursor] = cursor if cursor.present?
      body[:page] = page if page.present?
      get("/learn/v1/courses", body)
    end

    def get_course(course_id)
      get("/learn/v1/courses/#{course_id}")&.fetch("data")
    end

    def course_report(course_id)
      post("/api/course/reportCourseForUsers", body: { id_course: course_id })
    end

    def list_enrollments
      get("/api/enroll/enrollments").fetch("enrollments")
    end

    def list_reports(name: nil)
      reports = get("/api/report/listReports").fetch("report_list")
      return reports if name.nil?

      reports.select do |r|
        r.fetch("filter_name") == name
      end
    end

    # https://www.docebo.com/lms-docebo-api-third-party-integration/legacy-apis/
    def get_report(report_id, from:, count:, date_from: nil)
      # yyy-MM-dd HH:mm:ss UTC
      body = { id_report: report_id, from: from, count: count }
      if date_from.present?
        date_from = from.strftime("%Y-%m-%d %H:%M:%S")
        body[:date_from] = date_from
      end
      post("/api/report/extractRows", body: body)
    end

    def enrollments(course_id)
      post("/api/enroll/enrollments")#, body: { id_course: course_id })
    end

    def find_user(username:)
      response = get("/manage/v1/user", match_type: "full", search_text: username)
      users = Array(response.dig("data", "items"))
      users.detect do |u|
        u.fetch("username") == username
      end
    end

    def get_user(id:)
      response = get("/manage/v1/user/#{id}")
      response.fetch("data")
    end

    def deactivate_user(id:)
      expiration = convert_date(1.day.ago)
      response = put("/manage/v1/user/#{id}", expiration: expiration)
      data = response.fetch("data")
      success = data.fetch("success") == true
      ids_match = id.to_s == data.fetch("updated_id").to_s
      unless success && ids_match
        raise "Failed to expire user #{id}"
      end
    end

    def activate_user(id:)
      response = put("/manage/v1/user/#{id}", expiration: nil)
      data = response.fetch("data")
      success = data.fetch("success") == true
      ids_match = id.to_s == data.fetch("updated_id").to_s
      unless success && ids_match
        raise "Failed to activate user #{id}"
      end
    end

    def get_user_fields()
      response = get "/manage/v1/user_fields?page_size=50"
      Array(response.dig("data", "items"))
    end

    def get_user_field_info(id: nil, name: nil)
      field_id = if id.present?
        id
      else
        field = get_user_fields.detect do |f|
          f.fetch("title") == name
        end
        field.fetch("id")
      end

      response = get "/manage/v1/user_fields/#{field_id}"
      response.dig("data")
    end

    def find_option_id(field_name, option_name)
      field = get_user_field_info(name: field_name)
      option = field.fetch("dropdown_options").detect do |o|
        o.dig("translations", "english") == option_name
      end
      option.fetch("option_id")
    end

    def update_profile(id, attributes)
      attr_map = {
        first_name: { field: "firstname", type: :textfield },
        last_name: { field: "lastname", type: :textfield },
        email: { field: "email", type: :textfield },
      }

      field_map = {
        company_name: { field: ["1", "3"], type: :textfield },
        participant_country: { field: "4", type: :textfield },
        sector: { field: "7", type: :dropdown },
        region: { field: "15", type: :dropdown },
        organization_type: { field: "6", type: :dropdown },
        employees: { field: "8", type: :textfield },
        local_network_country: { field: "2", type: :textfield },
        joined_on: { field: "5", type: :date },
        first_name: { field: "10", type: :textfield },
        last_name: { field: "11", type: :textfield },
        email: { field: "13", type: :textfield },
        country: { field: "14", type: :textfield },
        ft500: { field: "9", type: :yesno },
        job_title: { field: "12", type: :textfield },
      }

      body = {
        additional_fields: {}
      }

      attributes.each do |k, v|
        if field_and_type = attr_map[k]
          docebo_key = field_and_type.fetch(:field)
          type = field_and_type.fetch(:type)

          body[docebo_key] = convert(type, v)
        end

        if field_and_type = field_map[k]
          field_keys = field_and_type.fetch(:field)
          type = field_and_type.fetch(:type)

          Array(field_keys).each_with_object(body[:additional_fields]) do |fid, fields|
            fields[fid] = convert(type, v)
          end
        end
      end

      response = put("/manage/v1/user/#{id}", body)
      response.fetch("data")
    end

    def convert(type, input)
      case type
        when :textfield then convert_textfield(input)
        when :dropdown then input
        when :date then convert_date(input)
        when :yesno then convert_boolean(input)
        else raise "Couldn't convert unexpected type #{type}"
      end
    end

    private

    def convert_textfield(input)
      input&.to_s
    end

    def convert_boolean(input)
      case input
        when nil then 0
        when true then 1
        when false then 2
      end
    end

    def convert_date(input)
      input&.strftime(DATE_FORMAT)
    end

    def post(url, body: {})
      response = @conn.post do |req|
        req.url url
        req.headers.merge!(headers)
        req.body = body.to_json
      end

      case response.status
        when 200
          JSON.parse(response.body)
        when 400
          rsp = JSON.parse(response.body)
          message = "#{rsp.fetch('error')}: #{rsp.fetch('error_description')}"
          raise "Docebo::Api error #{message}"
        else
          raise "Unexpected Docebo::Api response: #{response.body}"
      end
    end

    def put(url, body)
      response = @conn.put do |req|
        req.url url
        req.headers.merge!(headers)
        req.body = body.to_json
      end

      case response.status
        when 200
          JSON.parse(response.body)
        else
          raise "Unexpected Docebo::Api response #{response.status} => #{response.body}"
      end
    end

    def get(url, body = {})
      response = @conn.get do |req|
        req.url url
        req.headers.merge!(headers)
        req.body = body.to_json
      end

      case response.status
        when 200
          JSON.parse(response.body) || {}
        else
          ap response.body
          raise "unexpected status responds for list_users: #{response.status}"
      end
    end

    def headers
      headers = {
        "Accept" => "application/json",
        "User-Agent" => "UNGC Ruby Client",
        "Content-Type" => "application/json; charset=UTF-8",
      }

      if @access_token.present?
        headers["Authorization"] = "Bearer #{@access_token}"
      end

      headers
    end

  end
end
