class Redesign::Admin::AdminController < ApplicationController
  layout 'redesign/admin'

  before_filter :authenticate_contact!
end
