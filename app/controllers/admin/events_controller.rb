class Admin::EventsController < AdminController
  helper Admin::EventsHelper
  before_filter :no_organization_or_local_network_access
  before_filter :set_event,
    :only => [:show, :edit, :update, :approve, :revoke, :delete, :destroy]

  def new
    @event = Event.new
  end

  def create
    @event = Event.new event_params

    if @event.save
      add_taggings
      flash[:notice] = 'Event successfully created.'
      redirect_to action: 'index'
    else
      render action: 'new'
    end
  end

  def show
  end

  def edit
    @event = Event.new event_params, @event
  end

  def update
    if @event.update(event_params)
      flash[:notice] = 'Changes have been saved.'
      redirect_to action: 'index'
    else
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
    def add_taggings
      TaggingUpdater.new({
        topics: event_params[:topic_ids],
        issues: event_params[:issue_ids],
        sectors: event_params[:sector_ids]
      }, @event).update
    end

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
        :call_to_action_1_title,
        :call_to_action_1_link,
        :call_to_action_2_title,
        :call_to_action_2_link,
        :overview_description,
        :starts_at_string,
        :ends_at_string,
        :topic_ids => [],
        :issue_ids => [],
        :sector_ids => []
      )
    end
end
