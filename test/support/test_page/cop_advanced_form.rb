module TestPage
  class CopAdvancedForm < Base

    def initialize
      # @questionnaire = SampleCopQuestionnaire.new
    end

    def save_draft
      click_on 'Save Draft'
    end

    def checked?(id)
      field = find_field(id)
      field.try(:value) == "1"
    end

    def filled?(id, with:)
      # check the page to see if those two options are changed
      find_field id, with: with, visible: false
    end

    def free_text(id, text)
      fill_in id, with: text, visible: false
    end

    def submit
      click_on 'Submit'
      if has_validation_errors?
        self
      else
        CopDetail.new
      end
    end

    def submit_sample_pdf(language:)
      select language, from: 'communication_on_progress_cop_files_attributes_0_language_id'

      filepath = File.absolute_path('./test/fixtures/files/untitled.pdf')
      attach_file('communication_on_progress_cop_files_attributes_0_attachment', filepath)
    end

    def has_validation_error?(error_message)
      has_validation_errors? && has_content?(error_message)
    end

    def has_validation_errors?
      has_content?('There were problems with the following fields:')
    end
  end

end
