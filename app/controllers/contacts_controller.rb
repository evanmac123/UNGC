class ContactsController < ApplicationController

  def new
    @contact = JoinOrganizationForm.new
  end

  def create
    @contact = JoinOrganizationForm.new(contact_params)

    if @contact.save
      redirect_to new_contact_url, notice: I18n.t("organization.requested_to_join")
    else
      render :new
    end
  end

  private

  def find_organization
    Organization.find(contact_params.fetch(:organization_id))
  end

  def contact_params
    params.require(:contact).permit(
      :organization_id,
      :organization_name,
      :prefix,
      :first_name,
      :middle_name,
      :last_name,
      :job_title,
      :email,
      :phone,
      :address,
      :address_more,
      :city,
      :state,
      :postal_code,
      :country_id,
      :country_name,
    )
    end

end
