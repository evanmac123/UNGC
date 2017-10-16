# -*- coding: utf-8 -*-
class Admin::LevelOfParticipationsController < AdminController

  before_action :must_be_from_organization

  def new
    @form = Organization::LevelOfParticipationForm.from(find_organization)
  end

  def create
    @form = Organization::LevelOfParticipationForm.from(find_organization)
    @form.attributes = form_params
    if @form.save
      redirect_to dashboard_url, notice: I18n.t("level_of_participation.success")
    else
      render :new
    end
  end

  private

  def must_be_from_organization
    unless current_contact.from_organization?
      flash[:error] = I18n.t("notice.must_be_from_participation_to_choose_level_of_participation")
      redirect_to dashboard_url
    end
  end

  def form_params
    params.require(:level_of_participation).permit(
      :level_of_participation,
      :contact_point_id,
      :is_subsidiary,
      :parent_company_name,
      :parent_company_id,
      :annual_revenue,
      :confirm_financial_contact_info,
      :confirm_submission,
      :invoice_date,
      financial_contact: [
        :id,
        :prefix,
        :first_name,
        :middle_name,
        :last_name,
        :job_title,
        :email,
        :phone,
        :fax,
        :address,
        :address_more,
        :city,
        :state,
        :postal_code,
        :country_id,
      ]
    )
  end

  def find_organization
    current_contact.organization
  end

end
