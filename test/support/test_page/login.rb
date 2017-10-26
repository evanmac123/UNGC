module TestPage
  class Login < Base

    def visit
      super(path)
    end

    def path
      '/login'
    end

    def fill_in_username(username)
      @username = username
      fill_in('Username', with: username)
    end

    def fill_in_password(password)
      fill_in('Password', with: password)
    end

    def click_login
      click_on 'Login'
      contact = Contact.find_by(username: @username)

      case current_path
      when "/edit"
        transition_to ChangePassword.new(contact)
      when dashboard_path
        transition_to Dashboard.new(contact)
      else
        nil
      end
    end
    alias_method :submit, :click_login

  end
end
