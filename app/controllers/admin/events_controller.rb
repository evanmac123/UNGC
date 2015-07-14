class Admin::EventsController < AdminController
  helper Admin::EventsHelper
  before_filter :no_organization_or_local_network_access
  before_filter :set_event,
    :only => [:show, :edit, :update, :approve, :revoke, :delete, :destroy]

  def new
    @event = EventPresenter.new(Event.new)
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      flash[:notice] = 'Event successfully created.'
      redirect_to action: 'index'
    else
      @event = EventPresenter.new(@event)
      render action: 'new'
    end
  end

  def show
    @event = EventPresenter.new(@event)
  end

  def edit
    @event = EventPresenter.new(@event)
  end

  def update
    if @event.update_attributes(event_params)
      flash[:notice] = 'Changes have been saved.'
      redirect_to action: 'index'
    else
      @event = EventPresenter.new(@event)
      render action: 'edit'
    end
  end

  def approve
    @event.as_user(current_contact).approve!
    redirect_to action: 'index'
  end

  def revoke
    @event.as_user(current_contact).revoke!
    redirect_to action: 'index'
  end

  def destroy
    @event.destroy
    redirect_to action: 'index'
  end

  def index
    @paged_events ||= Event.paginate(page: params[:page]).order(order_from_params)
  end

  private
    def order_from_params
      @order = [params[:sort_field] || 'starts_at', params[:sort_direction] || 'ASC'].join(' ')
    end

    def set_event
      @event = Event.find(params[:id])
    end

    def event_params
      params.require(:event).permit(
        :title,
        :description,
        :starts_at,
        :ends_at,
        :is_all_day,
        :is_online,
        :location,
        :country_id,
        :is_invitation_only,
        :priority,
        :contact_id,
        :thumbnail_image,
        :banner_image,
        :call_to_action_1_label,
        :call_to_action_1_url,
        :call_to_action_2_label,
        :call_to_action_2_url,
        :programme_description,
        :starts_at_string,
        :ends_at_string,
        :media_description,
        :media_description,
        :tab_1_title,
        :tab_1_description,
        :tab_2_title,
        :tab_2_description,
        :tab_3_title,
        :tab_3_description,
        :sponsors_description,
        :sponsor_ids => [],
        :topic_ids => [],
        :issue_ids => [],
        :sector_ids => []
      )
    end
end
