class Admin::SponsorsController < AdminController
  before_filter :no_organization_or_local_network_access
  before_filter :set_sponsor,
    :only => [:show, :edit, :update, :delete, :destroy]

  def new
    @sponsor = Sponsor.new
  end

  def create
    @sponsor = Sponsor.new(sponsor_params)

    if @sponsor.save
      flash[:notice] = 'Sponsor successfully created.'
      redirect_to action: 'index'
    else
      render action: 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @sponsor.update_attributes(sponsor_params)
      flash[:notice] = 'Changes have been saved.'
      redirect_to action: 'index'
    else
      @sponsor = @sponsor
      render action: 'edit'
    end
  end

  def destroy
    @sponsor.destroy
    redirect_to action: 'index'
  end

  def index
    @paged_sponsors ||= Sponsor.paginate(page: params[:page]).order(order_from_params)
  end

  private
    def order_from_params
      @order = [params[:sort_field] || 'name', params[:sort_direction] || 'ASC'].join(' ')
    end

    def set_sponsor
      @sponsor = Sponsor.find(params[:id])
    end

    def sponsor_params
      params.require(:sponsor).permit(
        :name,
        :website_url,
        :logo_url,
        :starts_at_string,
        :ends_at_string
      )
    end
end
