module TestPage
  class Dashboard < Base

    def initialize(user)
      @user = user
    end

    def login
      login_as(@user)
    end

    def visit
      login
      super path
    end

    def path
      '/admin/dashboard'
    end

    def submit_cop
      click_on 'New Communication on Progress'
      CopLanding.new
    end

  end
end
