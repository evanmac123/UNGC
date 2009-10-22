class Admin::NewsController < AdminController
  helper Admin::NewsHelper
  before_filter :find_headline, :only => [:edit, :show, :update, :destroy, :delete]

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

  private
    def find_headline
      @headline = Headline.find_by_id(params[:id])
      redirect_to :action => 'index' unless @headline
    end

end
