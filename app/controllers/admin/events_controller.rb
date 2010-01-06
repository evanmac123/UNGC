class Admin::EventsController < AdminController
  helper Admin::EventsHelper
  before_filter :no_organization_or_local_network_access
  before_filter :find_event, 
    :only => [:approve, :delete, :destroy, :edit, :revoke, :show, :update]
  
  def index
  end

  def new
    @event = Event.new params[:event]
  end
  
  def create
    @event = Event.new params[:event]
    if @event.save
      flash[:notice] = "Event successfully created"
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
  end
  
  def update
    if @event.update_attributes(params[:event])
      flash[:notice] = "Changes have been saved"
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end

  def show
  end

  def destroy
    @event.destroy
    redirect_to :action => 'index'
  end

  def approve
    @event.as_user(current_user).approve!
    redirect_to :action => 'index'
  end
  
  def revoke
    @event.as_user(current_user).revoke!
    redirect_to :action => 'index'
  end
  
  private
  def find_event
    @event = Event.find_by_id(params[:id])
    redirect_to :action => 'index' unless @event
  end
end
