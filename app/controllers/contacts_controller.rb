class ContactsController < ApplicationController
  layout 'admin'
  before_filter :load_organization

  def new
    @contact = @organization.contacts.new(:country_id => @organization.country_id)
  end

  def create
    @contact = @organization.contacts.new(params[:contact])

    if @contact.save
      flash[:notice] = 'Contact was successfully created.'
      redirect_to @organization
    else
      render :action => "new"
    end
  end

  def update
    if @contact.update_attributes(params[:contact])
      flash[:notice] = 'Contact was successfully updated.'
      redirect_to @organization
    else
      render :action => "edit"
    end
  end

  def destroy
    if @contact.destroy
      flash[:notice] = 'Contact was successfully deleted.'
    else
      flash[:error] =  @contact.errors.full_messages.to_sentence
    end
    redirect_to @organization
  end
  
  private
    def load_organization
      @organization = Organization.find params[:organization_id]
      @contact = @organization.contacts.find params[:id] if params[:id]
    end
end
