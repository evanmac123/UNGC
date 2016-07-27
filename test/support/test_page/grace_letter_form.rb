module TestPage
  class GraceLetterForm < Base

    def initialize(organization)
      @organization = organization
    end

    def path
      new_admin_organization_grace_letter_path(@organization.id)
    end

    def select_language(language)
      select language, from: 'grace_letter[language_id]'
    end

    def choose_letter(filename)
      path = File.absolute_path(File.join(['.', 'test', 'fixtures', 'files', filename]))
      attach_file('grace_letter[attachment]', path)
    end

    def extended_due_date
      find('strong[role=extended_due_date]').text
    end

    def submit
      click_on 'Submit'
    end

    def validation_errors
      all('#errorExplanation li').map(&:text)
    end

    def flash_text
      find('.flash').text
    end

  end
end
