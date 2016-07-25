module TestPage
  class Base
    include Capybara::DSL
    include Warden::Test::Helpers
    include Rails.application.routes.url_helpers

    def visit(path, code = 200)
      super(path)
      ensure_path(path, code)
    end

    def transition_to(other_page)
      other_page.tap do |p|
        ensure_path(p.path)
      end
    end

    def ensure_path(path, code = 200)
      errors = []
      if path_and_query != path
        errors << "Expected #{path}, got #{path_and_query}"
      end

      if page.status_code != code
        errors << "Expected status code: #{code}, got #{page.status_code}"
      end

      if errors.any?
        raise errors.to_sentence
      end
    end

    def path_and_query
      uri = URI.parse(current_url)
      if uri.query.present?
        "#{uri.path}?#{uri.query}"
      else
        uri.path
      end
    end

    def log
      just_the_path = URI.parse(path).path
      filepath = File.expand_path("./public/system#{just_the_path}.html")
      FileUtils.mkdir_p(File.dirname(filepath))
      File.open(filepath, 'w') do |f|
        f.write(page.html.gsub('display: none;', ''))
      end
      system "open http://localhost:3000/system#{just_the_path}.html"
    end

    def flash_text
      find('.flash').text
    end

  end
end
