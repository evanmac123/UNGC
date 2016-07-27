module TestPage
  class CopAdvancedForm < Base

    def initialize(organization)
      @organization = organization
    end

    def path
      new_admin_organization_communication_on_progress_path(@organization.id,
                                                            type_of_cop: 'advanced')
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

    def title=(value)
      fill_in 'communication_on_progress[title]', with: value
    end

    def format=(value)
      choose value
    end

    def format
      find_field('communication_on_progress[format]', checked: true).value
    end

    def starts_on
      date_from('starts_on')
    end

    def start_date(month, year)
      select_date('starts_on', month, year)
    end

    def ends_on
      date_from('ends_on')
    end

    def end_date(month, year)
      select_date('ends_on', month, year)
    end

    def include_continued_support_statement=(value)
      choose "communication_on_progress_include_continued_support_statement_#{value}"
    end

    def include_continued_support_statement?(value = true)
      find_field("communication_on_progress_include_continued_support_statement_#{value}", checked: true)
    end

    def references(area, value)
      choose "communication_on_progress_references_#{area}_#{value}"
    end

    def references?(area, value = true)
      selector = "communication_on_progress[references_#{area}]"
      field = find_field(selector, checked: true)
      field.value == "true"
    rescue Capybara::ElementNotFound
      nil
    end

    def include_measurement=(value)
      choose "communication_on_progress_include_measurement_#{value}"
    end

    def include_measurement?
      find_field("communication_on_progress[include_measurement]", checked: true)
    end

    def method_shared_with_stakeholders=(method)
      choose method
    end

    def method_shared_with_stakeholders
      find_field("communication_on_progress[method_shared]", checked: true).value
    end

    def free_text(id, text)
      fill_in id, with: text, visible: false
    end

    def submit
      click_on 'Submit'
      if has_validation_errors?
        self
      else
        match = current_path.match(/communication_on_progresses\/(\d+)/)
        cop = @organization.communication_on_progresses.find(match[1])
        transition_to CopDetail.new(cop)
      end
    end

    def add_file(language:, filename:)
      select language, from: 'communication_on_progress_cop_files_attributes_0_language_id'

      filepath = File.absolute_path("./test/fixtures/files/#{filename}")
      attach_file('communication_on_progress_cop_files_attributes_0_attachment', filepath)
    end

    def add_link(language:, url:)
      select language, from: 'communication_on_progress_cop_links_attributes_0_language_id'
      fill_in 'communication_on_progress_cop_links_attributes_0_url', with: url
    end

    def has_validation_error?(error_message)
      has_validation_errors? && has_content?(error_message)
    end

    def has_validation_errors?
      has_content?('There were problems with the following fields:')
    end

    private

    def date_from(field)
      month = find_field("communication_on_progress[#{field}(2i)]").value.to_i
      year = find_field("communication_on_progress[#{field}(1i)]").value.to_i
      Date.new(year, month, 1)
    end

    def select_date(field, month, year)
      select month, from: "communication_on_progress[#{field}(2i)]"
      select year, from: "communication_on_progress[#{field}(1i)]"
    end

  end

end
