class Admin::ContactsController < AdminController
  before_filter :load_organization

  def new
    @contact = @organization.contacts.new(:country_id => @organization.country_id)
    @roles = Role.visible_to(@contact)
  end

  def create
    @contact = @organization.contacts.new(params[:contact])
    @roles = Role.visible_to(@contact)

    if @contact.save
      flash[:notice] = 'Contact was successfully created.'
      redirect_to admin_organization_path(@organization.id)
    else
      render :action => "new"
    end
  end

  def update
    if @contact.update_attributes(params[:contact])
      flash[:notice] = 'Contact was successfully updated.'
      redirect_to admin_organization_path(@organization.id)
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
    redirect_to admin_organization_path(@organization.id)
  end
  
  private
    def load_organization
      @organization = Organization.visible_to(current_user).find params[:organization_id]
      if params[:id]
        @contact = @organization.contacts.find params[:id]
        @roles = Role.visible_to(@contact)
      end
    end
end
