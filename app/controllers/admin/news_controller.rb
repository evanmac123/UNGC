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
    @headline = Headline.new headline_params
  end

  def create
    @headline = Headline.new headline_params
    if @headline.save
      flash[:notice] = "Headline successfully created"
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @headline.update_attributes(headline_params)
      flash[:notice] = "Changes have been saved"
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end

  def show
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
        :description
      )
    end
end
