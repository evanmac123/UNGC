class AdminController < ApplicationController
  layout 'admin'
  before_filter :require_staff
  
  private
  def require_staff # TODO: Make this secure
    true
  end
end