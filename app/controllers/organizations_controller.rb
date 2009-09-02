class OrganizationsController < ApplicationController
  before_filter :load_organization, :only => [:show, :edit, :update, :destroy, :approve, :reject]
  
  def index
    @organizations = Organization.paginate :per_page => 10, :page => params[:page]
  end

  def new
    @organization = Organization.new
    @organization.contacts << @organization.contacts.new
  end

  def create
    @organization = Organization.new(params[:organization])

    if @organization.save
      flash[:notice] = 'Organization was successfully created.'
      redirect_to(@organization)
    else
      render :action => "new"
    end
  end

  def update
    if @organization.update_attributes(params[:organization])
      flash[:notice] = 'Organization was successfully updated.'
      redirect_to(@organization)
    else
      render :action => "edit"
    end
  end

  def destroy
    @organization.destroy
    redirect_to(organizations_url)
  end

  def approve
    @organization.approve
    redirect_to(@organization)
  end

  def reject
    @organization.reject
    redirect_to(@organization)
  end

  %w{approved rejected pending}.each do |method|
    define_method method do
      @organizations = Organization.send method
      render 'index'
    end
  end

  private
    def load_organization
      @organization = Organization.find(params[:id])
    end
end