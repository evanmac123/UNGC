class Admin::ContactsController < AdminController
  before_filter :load_parent, except: [:search]

  def new
    @contact = @parent.contacts.new
    @contact.country_id = @parent.country_id if @parent.respond_to?(:country_id)
    @roles = visible_roles
    @return_path = return_path
  end

  def create
    @contact = @parent.contacts.new(contact_params)
    creator = Contact::Creator.new(@contact, policy)

    if creator.create
      flash[:notice] = 'Contact was successfully created.'
      redirect_to return_path
    else
      @roles = visible_roles
      @return_path = return_path

      render :action => "new"
    end
  end

  def edit
    @needs_to_update = params[:update]
    @roles = visible_roles
    @return_path = return_path
  end

  def update
    updater = Contact::Updater.new(@contact, policy)

    if updater.update(contact_params)
      if @contact.id == current_contact.id
        sign_in(@contact, :bypass => true)
      end

      flash[:notice] = 'Contact was successfully updated.'
      redirect_to return_path
    else
      # Temporary, we're seeing unexpected failures here.
      Honeybadger.notify({
        error_class:    'FAILED_CONTACT_UPDATE',
        error_message:  "#{@contact.errors.full_messages.to_sentence}",
        parameters:     {
          contact: @contact.attributes,
          params: params
        }
      })

      @roles = visible_roles
      @return_path = return_path

      render :action => "edit"
    end
  end

  def destroy
    can_destroy = policy.can_destroy?(@contact)
    unless can_destroy
      @contact.errors.add(:base, "You are not authorized to delete that contact.")
    end

    if can_destroy && @contact.destroy
      flash[:notice] = 'Contact was successfully deleted.'
    else
      flash[:error] = @contact.errors.full_messages.to_sentence
    end
    redirect_to return_path
  end

  def search
    if params[:commit] == 'Search'
      display_search_results
    end
  end

  def reset_password
    if @contact.update(email: contact_params.fetch(:email))
      token = @contact.send_reset_password_instructions
      if token.present?
        flash[:notice] = "This contact's email was changed to #{@contact.email} and a password reset email was sent."
      else
        flash[:notice] = "Failed to send password reset email"
      end
      redirect_to url_for [:edit, :admin, @parent, @contact]
    else
      @needs_to_update = params[:update]
      @roles = visible_roles
      @return_path = return_path
      render :edit
    end
  end

  private
    def load_parent
      loader = ContactLoader.new(self)
      if id = params[:organization_id]
        loader.load_organization(id)
      elsif id = params[:local_network_id]
        loader.load_local_network(id)
      end
      loader.load_contact(params[:id])

      @parent = loader.parent
      @contact = loader.contact
      @roles = loader.roles
      @reset_password_path = loader.reset_password_path
    end

    def visible_roles
      Role.visible_to(@contact, current_contact)
    end

    def display_search_results
      keyword = params[:keyword].force_encoding("UTF-8")
      options = {
        per_page: (params[:per_page] || 15).to_i,
        page: params[:page]
      }
      options[:with] ||= {}
      options[:with].merge!(email: params[:email]) if params[:email]

      # store what we searched_for so that the helper can pick it apart and make a pretty label
      @searched_for = keyword
      @results = Contact.search Riddle::Query.escape(keyword), options
      raise Riddle::ConnectionError unless @results && @results.total_entries
      render :action => 'search_results'
    end

    def return_path
      if current_contact.from_ungc? || current_contact.from_network?
        contact_parent_path(@contact, [], [], :tab => :contacts)
      else
        dashboard_path(:tab => :contacts)
      end
    end

    def network_management_tab?
      true
    end

    def contact_params
      params.fetch(:contact, {}).permit(
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
        :username,
        :password,
        :image,
        role_ids: []
      )
    end

    def policy
      @policy ||= ContactPolicy.new(current_contact)
    end

    class ContactLoader
      attr_reader :parent, :contact, :roles

      def initialize(controller)
        @controller = controller
      end

      def load_organization(id)
        @kind = :organization
        @parent = Organization.visible_to(current_contact).find(id)
      end

      def load_local_network(id)
        @kind = :local_network
        @parent = LocalNetwork.find(id)
      end

      def load_contact(id)
        return if id.nil?

        @contact = @parent.contacts.find(id)
        @roles = Role.visible_to(@contact, current_contact)
      end

      def reset_password_path
        return if @contact.nil?

        case @kind
        when :organization
          @controller.reset_password_admin_organization_contact_path(@parent.id, @contact.id)
        when :local_network
          @controller.reset_password_admin_local_network_contact_path(@parent.id, @contact.id)
        else
          raise "Unexpected contact kind: '#{@kind}'."
        end
      end

      def current_contact
        @controller.current_contact
      end

    end

end
