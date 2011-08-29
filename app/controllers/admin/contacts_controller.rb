class Admin::ContactsController < AdminController
  before_filter :load_parent, :except => :search

  def new
    @contact = @parent.contacts.new
    @contact.country_id = @parent.country_id if @parent.respond_to?(:country_id)
    @roles = Role.visible_to(@contact, current_user)
  end

  def create
    @contact = @parent.contacts.new(params[:contact])
    @roles = Role.visible_to(@contact)

    if @contact.save
      flash[:notice] = 'Contact was successfully created.'
      redirect_user_to_appropriate_screen
    else
      render :action => "new"
    end
  end

  def edit
    @needs_to_update = params[:update]
    @roles = Role.visible_to(@contact, current_user)
  end

  def update
    if @contact.update_attributes(params[:contact])
      flash[:notice] = 'Contact was successfully updated.'
      redirect_user_to_appropriate_screen
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
    redirect_user_to_appropriate_screen
  end
  
  def search
    if params[:commit] == 'Search'
      display_search_results
    end
  end
  
  private
    def load_parent
      @parent = if params[:organization_id]
                  Organization.visible_to(current_user).find params[:organization_id]
                elsif params[:local_network_id]
                  LocalNetwork.find params[:local_network_id]
                end

      if params[:id]
        @contact = @parent.contacts.find params[:id]
        @roles = Role.visible_to(@contact)
      end
    end
    
    def display_search_results
      keyword = params[:keyword].force_encoding("UTF-8")
      options = {per_page: (params[:per_page] || 15).to_i,
                 page: params[:page],
                 star: true}
      options[:with] ||= {}
      options[:with].merge!(email: params[:email]) if params[:email]

      # store what we searched_for so that the helper can pick it apart and make a pretty label
      @searched_for = keyword
      @results = Contact.search keyword, options
      raise Riddle::ConnectionError unless @results && @results.total_entries
      render :action => 'search_results'
    end
    
    def redirect_user_to_appropriate_screen
      if current_user.from_ungc?
        redirect_to contact_parent_path(@contact, [], [], :tab => :contacts)
      else
        redirect_to dashboard_path(:tab => :contacts) 
      end
    end

end
