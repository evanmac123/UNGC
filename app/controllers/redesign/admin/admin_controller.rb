class Redesign::Admin::AdminController < ApplicationController
  layout 'redesign/admin'

  before_action :authenticate_contact!
  before_action :only_ungc_contacts!

  def only_ungc_contacts!
    unless current_contact.from_ungc?
      flash[:error] = "You do not have permission to access that resource."
      redirect_to dashboard_path
    end
  end
end
