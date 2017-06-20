class DonationsController < ApplicationController

  def index
    set_current_container_by_path("/about/foundation")
    url = new_donation_path(contact_id: contact_id, organization_id: organization_id)
    @page = AboutFoundationPage.new(current_container, current_payload_data, url)
    render "static/#{current_container.layout}"
  end

  def confirmation
  end

  def new
    contact = Contact.find_by(id: contact_id) || current_contact
    if contact.present?
      @donation = Donation::Form.from(contact: contact)
    else
      @donation = Donation::Form.new
    end
  end

  def create
    @donation = Donation::Form.new(donation_params)
    if Donation::ChargeDonor.charge(@donation)
      message = if @donation.succeeded?
                  "Your donation of #{@donation.amount.format} has been accepted."
                else
                  "We were unable to process your donation"
                end
      redirect_to donation_confirmation_url, notice: message
    else
      render :new
    end
  end

  private

  def contact_id
    params[:contact_id]
  end

  def organization_id
    params[:organization_id]
  end

  def donation_params
    params.require(:donation)
      .permit(
        :amount,
        :job_title,
        :first_name,
        :last_name,
        :email_address,
        :company_name,
        :address,
        :address_more,
        :city,
        :state,
        :postal_code,
        :country_name,
        :name_on_card,
        :contact_id,
        :organization_id,
        :token,
        :invoice_number,
        :credit_card_type
      )
  end

end
