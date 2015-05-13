class Redesign::ContactUsController < Redesign::ApplicationController

  def new
    @contact_us = Redesign::ContactUsForm.new
    @page = ContactUsPage.new(current_container)
  end

  def create
    @contact_us = Redesign::ContactUsForm.new(contact_us_params)
    @page = ContactUsPage.new(current_container)

    if @contact_us.send_email
      redirect_to redesign_contact_us_path, notice: 'Contact email was sent successfully.'
    else
      render :new
    end
  end

  private
    def contact_us_params
      params.require(:redesign_contact_us_form).permit(
        :name,
        :email,
        :organization,
        :comments,
        :interest_ids => [],
        :focus_ids => []
      )
    end
end
