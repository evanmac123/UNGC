module TestPage
  class ChooseLevelOfParticipation < Base

    def visit
      super(path)
    end

    def path
      admin_choose_level_of_participation_path
    end

    def select_level_of_participation(level)
      choose level
    end

    def confirm_contact_point(contact)
      select contact.name, from: I18n.t("level_of_participation.confirm_primary_contact_point")
    end

    def is_subsidiary=(value)
      choose("level_of_participation[is_subsidiary]", option: value)
    end

    def subsidiary_of(parent_organization)
      fill_in "level_of_participation_parent_company_name", with: parent_organization.name
      find(:xpath, "//input[@id='level_of_participation_parent_company_id']", visible: :all).set(parent_organization.id)
    end

    def annual_revenue=(value)
      fill_in I18n.t("level_of_participation.confirm_annual_revenue"), with: value
    end

    def create_financial_contact(params)
      choose "Create new financial contact"

      country_name = params.delete(:country)
      select country_name, from: "level_of_participation[financial_contact][country_id]"

      # Quick and dirty way of mapping contact attributes to text labels.
      # If we hit an exception, we'll have to do it manually
      params.each do |key, value|
        fill_in key.to_s.humanize, with: value
      end
    end

    def choose_from_existing_contacts
      choose "Choose from existing contacts"
    end

    def assign_financial_contact_role_to(contact)
      choose_from_existing_contacts
      select contact.name, from: "Please choose or confirm your financial contact"
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

    def validation_errors
      all(:css, "#errorExplanation li").map(&:text).to_sentence
    end

    def signup_for_action_platform(platform, contact)
      platform_selector = "level_of_participation_subscriptions_#{platform.id}_selected"
      contact_selector = "level_of_participation_subscriptions_#{platform.id}_contact_id"
      check(platform_selector)
      select(contact.name, from: contact_selector)
    end

    def accept_platform_removal
      check(I18n.t("level_of_participation.accept_platform_removal"))
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
