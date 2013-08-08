class Admin::ResourcesController < AdminController

  def index
    @resources = Resource.order(order_from_params).paginate(:page     => params[:page],
                                  :per_page => Organization.per_page)
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end

  def destroy
  end

  private
    def order_from_params
      @order = [params[:sort_field] || 'updated_at', params[:sort_direction] || 'DESC'].join(' ')
    end

end
