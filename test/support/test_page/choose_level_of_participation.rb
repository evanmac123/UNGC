module TestPage
  class ChooseLevelOfParticipation < Base

    def visit
      super(path)
    end

    def path
      admin_choose_level_of_participation_path
    end

    def select_level_of_participation(level)
      choose level.upcase
    end

    def confirm_contact_point(contact)
      select contact.name, from: I18n.t("level_of_participation.confirm_primary_contact_point")
    end

    def is_subsidiary=(value)
      choose("level_of_participation[is_subsidiary]", option: value)
    end

    def subsidiary_of(parent_organization)
      fill_in "level_of_participation_parent_company_name", with: parent_organization.name
      find(:xpath, "//input[@id='level_of_participation_parent_company_id']").set(parent_organization.id)
    end

    def annual_revenue=(value)
      fill_in I18n.t("level_of_participation.confirm_annual_revenue"), with: value
    end

    def contact_middle_name=(value)
      fill_in "Middle name", with: value
    end

    def confirm_financial_contact_info
      check I18n.t("level_of_participation.confirm_financial_contact_info")
    end

    def invoice_on_cop_due_date_of(organization)
      choose I18n.t("level_of_participation.invoice_on_next_cop_due_date",
        cop_due_on: organization.cop_due_on)
      fill_in "level_of_participation[invoice_date]", with: format_date(organization.cop_due_on)
    end

    def invoice_me_now
      choose "Invoice me now"
      fill_in "level_of_participation[invoice_date]", with: format_date(today)
    end

    def confirm_submission
      check I18n.t("level_of_participation.confirm_submission")
    end

    def submit
      click_on "Confirm"
    end

    def has_validation_error?(message)
      page.has_content? message
    end

    private

    def format_date(date)
      date.strftime("%d-%m-%Y")
    end

    def today
      Time.zone.now.to_date
    end
  end
end
