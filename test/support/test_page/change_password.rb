module TestPage
  class ChangePassword < Base

    def initialize(contact)
      @contact = contact
    end

    def path
      edit_contact_registration_path
    end

    def fill_in_new_password(password)
      fill_in 'Password', with: password
    end

    def fill_in_password_confirmation(password)
      fill_in 'Password confirmation', with: password
    end

    def fill_in_old_password(password)
      fill_in 'Current password', with: password
    end

    def click_update
      click_on 'Update'

      if current_path == '/'
        self
      else
        transition_to Dashboard.new(@contact)
      end
    end

    def visit
      super(path)
      transition_to self
    end

    def error_messages
      all('#error_explanation li').map(&:text)
    end

  end
end
