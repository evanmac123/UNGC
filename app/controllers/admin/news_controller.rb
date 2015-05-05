class Admin::NewsController < AdminController
  helper Admin::NewsHelper
  before_filter :no_organization_or_local_network_access
  before_filter :find_headline,
    :only => [:approve, :delete, :destroy, :edit, :revoke, :show, :update]

  def index
    @paged_headlines ||= Headline.paginate(page: params[:page])
                                 .order(order_from_params)
  end

  def new
    @headline = HeadlinePresenter.new(Headline.new)
  end

  def create
    updater = HeadlineUpdater.new(headline_params)
    if updater.submit
      redirect_to admin_headlines_url, notice: 'Headline successfully created.'
    else
      @headline = HeadlinePresenter.new(updater.headline)
      render action: 'new'
    end
  end

  def show
    @headline = HeadlinePresenter.new(@headline)
  end

  def edit
    @headline = HeadlinePresenter.new(@headline)
  end

  def update
    updater = HeadlineUpdater.new(headline_params, @headline)
    if updater.submit
      redirect_to admin_headlines_url, notice: 'Headline successfully updated.'
    else
      @headline = HeadlinePresenter.new(@headline)
      render action: 'edit'
    end
  end

  def destroy
    @headline.destroy
    redirect_to :action => 'index'
  end

  def approve
    @headline.as_user(current_contact).approve!
    redirect_to :action => 'index'
  end

  def revoke
    @headline.as_user(current_contact).revoke!
    redirect_to :action => 'index'
  end

  private
    def find_headline
      @headline = Headline.find_by_id(params[:id])
      redirect_to :action => 'index' unless @headline
    end


    def order_from_params
      @order = [params[:sort_field] || 'published_on', params[:sort_direction] || 'DESC'].join(' ')
    end

    def headline_params
      return {} if params[:headline].blank?

      params.require(:headline).permit(
        :title,
        :published_on,
        :location,
        :country_id,
        :description,
        :headline_type,
        topics: [],
        issues: [],
        sectors: []
      )
    end
end
