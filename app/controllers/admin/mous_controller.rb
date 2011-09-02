class Admin::MousController < AdminController
  before_filter :load_local_network
  before_filter :load_mou, :only => [:show, :edit, :update, :destroy]

  def show
    file = @mou.file
    send_file file.full_filename, :type => file.content_type, :disposition => 'inline'
  end

  def new
    @mou = @local_network.mous.build
  end

  def create
    @mou = @local_network.mous.build(params[:mou])

    if @mou.save
      flash[:notice] = 'MOU was successfully uploaded.'
      redirect_user_to_appropriate_screen
    else
      render :action => "new"
    end
  end

  def update
    @mou.attributes = params[:mou]

    if @mou.save
      flash[:notice] = 'MOU was successfully updated.'
      redirect_user_to_appropriate_screen
    else
      render :action => "edit"
    end
  end

  def destroy
    if @mou.destroy
      flash[:notice] = 'MOU was successfully deleted.'
    else
      flash[:error] =  @mou.errors.full_messages.to_sentence
    end

    redirect_user_to_appropriate_screen
  end

  private

  def load_local_network
    @local_network = LocalNetwork.find(params[:local_network_id])
  end

  def load_mou
    @mou = @local_network.mous.find(params[:id])
  end    

  def redirect_user_to_appropriate_screen
    if current_user.from_ungc?
      redirect_to admin_local_network_path(@local_network, :tab => :mou)
    else
      redirect_to dashboard_path(:tab => :mou)
    end
  end
end

