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

      if current_path == '/edit'
        transition_to ChangePassword.new(contact)
      else
        transition_to Dashboard.new(contact)
      end
    end

  end
end
