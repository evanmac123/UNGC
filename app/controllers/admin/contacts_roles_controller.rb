class Admin::ContactsRolesController < AdminController
  before_filter :load_contact_and_role

  def create
    @contact.roles << @role
    redirect_to :back
  end

  def destroy
    @contact.roles.delete(@role)
    redirect_to :back
  end

  private
    def load_contact_and_role
      @contact = Contact.find params[:contact_id]
      @role = Role.find params[:role_id]
    end
end
