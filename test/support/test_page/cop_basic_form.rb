module TestPage
  class CopBasicForm < Base

    def initialize(organization)
      @organization = organization
    end

    def path
      new_admin_organization_communication_on_progress_path(@organization.id,
                                                            type_of_cop: 'basic')
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

    def format=(value)
      choose value
    end

    def format
      find_field('communication_on_progress[format]', checked: true).value
    end

    def fill_in_title(title)
      fill_in 'communication_on_progress[title]', with: title
    end

    def starts_on
      date_from('starts_on')
    end

    def select_start_date(month, year)
      select_date('starts_on', month, year)
    end

    def ends_on
      date_from('ends_on')
    end

    def select_end_date(month, year)
      select_date('ends_on', month, year)
    end

    def check_continued_support_statement(value)
      choose "communication_on_progress_include_continued_support_statement_#{value}"
    end

    def include_continued_support_statement?(value = true)
      find_field("communication_on_progress_include_continued_support_statement_#{value}", checked: true)
    end

    def check_reference(area, value)
      choose "communication_on_progress_references_#{area}_#{value}"
    end

    def references?(area, value = true)
      selector = "communication_on_progress[references_#{area}]"
      field = find_field(selector, checked: true)
      field.value == "true"
    rescue Capybara::ElementNotFound
      nil
    end

    def check_include_measurement(value)
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

    def fill_question(partial_question_text, with: nil, tab: nil)
      field = find_question(partial_question_text, tab)
      field.set(with || partial_question_text)
    end

    def find_answer_to(partial_question_text, tab: nil)
      field = find_question(partial_question_text, tab)
      field.value
    end

    def submit
      click_on 'Submit'
      if has_validation_errors?
        self
      else
        match = current_path.match(/communication_on_progresses\/(\d+)/)
        if match
          cop = @organization.communication_on_progresses.find(match[1])
          transition_to CopDetail.new(cop)
        else
          raise "Expected successful form submittion to transition to the show page. Got #{current_path} instead."
        end
      end
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

    def find_question(partial_question_text, tab)
      # <div class="principles">
      #   <h3>
      #     <span class="human_right">Human Rights</span>
      #   </h3>
      # </div>
      # ...
      #   <p class='question_text'>Attribute#text</p>
      #   <textarea />

      selector = ['//']

      if tab.present?
        # prefix the selection with the tab matching title as context
        selector << "div[@class='tab_content' and ./div[@class='principles']/h3/span[contains(text(), '#{tab}')]]//"
      end

      # the textarea following the .question_text containing partial_question_text
      selector << "p[@class='question_text' and contains(text(), '#{partial_question_text}')]/following-sibling::textarea"

      find(:xpath, selector.join)
    end
  end

end
