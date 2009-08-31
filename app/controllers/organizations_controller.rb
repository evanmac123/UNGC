class OrganizationsController < ApplicationController
  def index
    @organizations = Organization.paginate :per_page => 10, :page => params[:page]
  end

  def show
    @organization = Organization.find(params[:id])
  end

  def new
    @organization = Organization.new
    @organization.contacts << @organization.contacts.new
  end

  def edit
    @organization = Organization.find(params[:id])
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
    @organization = Organization.find(params[:id])

    if @organization.update_attributes(params[:organization])
      flash[:notice] = 'Organization was successfully updated.'
      redirect_to(@organization)
    else
      render :action => "edit"
    end
  end

  def destroy
    @organization = Organization.find(params[:id])
    @organization.destroy
    redirect_to(organizations_url)
  end
end
