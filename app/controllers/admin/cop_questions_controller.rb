class Admin::CopQuestionsController < AdminController
  before_filter :no_organization_or_local_network_access, :only => [:index, :new, :edit, :create, :update, :destroy]
  before_filter :fetch_question, :only => [:destroy, :update, :edit]

  def index
    conditions = {}
    conditions[:year] = params[:year] if params[:year].present?
    conditions[:year] = nil if conditions[:year] == 'no_year'
    session[:year_filter] = params[:year]
    @cop_questions = CopQuestion.all(:order => 'position, grouping, year', :conditions => conditions)
  end

  def new
    @cop_question = CopQuestion.new
    @cop_question.year = session[:year_filter]
  end

  def create
    @cop_question = CopQuestion.new(params[:cop_question])
    if @cop_question.save
      flash[:notice] = 'COP Question was successfully created.'
      redirect_to admin_cop_questions_path(:year => session[:year_filter])
    else
      render :action => "new"
    end
  end

  def edit
  end

  def update
    if @cop_question.update_attributes(params[:cop_question])
      flash[:notice] = 'COP Question was successfully updated.'
      redirect_to admin_cop_questions_path(:year => session[:year_filter])
    else
      render :action => "edit"
    end
  end

  def destroy
    @cop_question.destroy
    redirect_to admin_cop_questions_path(:year => session[:year_filter])
  end

  private

  def fetch_question
    @cop_question = CopQuestion.find(params[:id])
  end

end
