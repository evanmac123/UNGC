class ContactUsController < Redesign::ApplicationController

  def new
    @contact_us = ContactUsForm.new
    @page = load_page
  end

  def create
    @contact_us = ContactUsForm.new(contact_us_params)
    @page = load_page

    if @contact_us.send_email
      redirect_to contact_us_path, notice: 'Contact email was sent successfully.'
    else
      render :new
    end
  end

  private
    def load_page
      set_current_container_by_path '/about/contact'
      ArticleFormPage.new(current_container, current_payload_data)
    end

    def contact_us_params
      params.require(:contact_us_form).permit(
        :name,
        :email,
        :organization,
        :comments,
        :magic,
        :interest_ids => [],
        :focus_ids => []
      )
    end
end
