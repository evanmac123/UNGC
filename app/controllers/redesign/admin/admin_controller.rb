class Redesign::Admin::AdminController < ApplicationController
  layout 'redesign/admin'

  before_filter :authenticate_contact!
  before_filter :only_ungc_contacts!

  def only_ungc_contacts!
    unless current_contact.from_ungc?
      flash[:error] = "You do not have permission to access that resource."
      redirect_to dashboard_path
    end
  end
end
