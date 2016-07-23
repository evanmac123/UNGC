module TestPage
  class Dashboard < Base

    def initialize(user)
      @user = user
      @organization = user.organization
      login
    end

    def login
      login_as(@user)
    end

    def visit
      super path
    end

    def path
      '/admin/dashboard'
    end

    def submit_cop
      click_on 'New Communication on Progress'
      transition_to CopLanding.new(@organization)
    end

    def organization_status
      all('#overview dd')[1].text
    end

    def find_cop_with_title(title)
      selector = "//table[@id='cops_dashboard_table']/tr/td[text() = '#{title}']"
      find(:xpath, selector)
    end

    def draft_cop_count
      all(:xpath, "//div[@id='cop_drafts']//tr").count
    end

  end
end
