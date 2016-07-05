module TestPage
  class Base
    include Capybara::DSL
    include Warden::Test::Helpers
    include Rails.application.routes.url_helpers

    def visit(path, code = 200)
      super(path)

      errors = []
      if current_path != path
        errors << "Expected #{path}, got #{current_path}"
      end

      if page.status_code != code
        errors << "Expected status code: #{code}, got #{page.status_code}"
      end

      if errors.any?
        raise errors.to_sentence
      end
    end

  end
end
