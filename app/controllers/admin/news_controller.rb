class Admin::NewsController < AdminController
  helper Admin::NewsHelper
  before_filter :no_organization_or_local_network_access
  before_filter :find_headline, 
    :only => [:approve, :delete, :destroy, :edit, :revoke, :show, :update]

  def index
  end

  def new
    @headline = Headline.new params[:headline]
  end
  
  def create
    @headline = Headline.new params[:headline]
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
    if @headline.update_attributes(params[:headline])
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
    @headline.as_user(current_user).approve!
    redirect_to :action => 'index'
  end
  
  def revoke
    @headline.as_user(current_user).revoke!
    redirect_to :action => 'index'
  end

  private
    def find_headline
      @headline = Headline.find_by_id(params[:id])
      redirect_to :action => 'index' unless @headline
    end

end
