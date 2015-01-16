class Admin::EventsController < AdminController
  helper Admin::EventsHelper
  before_filter :no_organization_or_local_network_access
  before_filter :find_event,
    :only => [:approve, :delete, :destroy, :edit, :revoke, :show, :update]

  def index
    @paged_events ||= Event.paginate(page: params[:page]).order(order_from_params)
  end

  def new
    @event = Event.new event_params
  end

  def create
    @event = Event.new event_params
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
    if @event.update_attributes(event_params)
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
    @event.as_user(current_contact).approve!
    redirect_to :action => 'index'
  end

  def revoke
    @event.as_user(current_contact).revoke!
    redirect_to :action => 'index'
  end

  private
    def find_event
      @event = Event.find_by_id(params[:id])
      redirect_to :action => 'index' unless @event
    end

    def order_from_params
      @order = [params[:sort_field] || 'starts_on', params[:sort_direction] || 'ASC'].join(' ')
    end

    def event_params
      return {} unless params[:event].present?

      params.require(:event).permit(
        :title,
        :description,
        :starts_on_string,
        :ends_on_string,
        :location,
        :country_id,
        :urls,
      )
    end
end
