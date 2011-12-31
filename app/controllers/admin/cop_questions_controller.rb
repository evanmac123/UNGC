class Admin::CopQuestionsController < AdminController
  before_filter :no_organization_or_local_network_access

  def index
    conditions = {}
    conditions[:year] = params[:year] if params[:year].present?
    @cop_questions = CopQuestion.all(:order => 'year, grouping, position', :conditions => conditions)
  end

  def new
    @cop_question = CopQuestion.new
  end

  def edit
    @cop_question = CopQuestion.find(params[:id])
  end

  def create
    @cop_question = CopQuestion.new(params[:cop_question])
    if @cop_question.save
      flash[:notice] = 'COP Question was successfully created.'
      redirect_to admin_cop_questions_path(:year => @cop_question.year)
    else
      render :action => "new"
    end
  end

  def update
    @cop_question = CopQuestion.find(params[:id])
    if @cop_question.update_attributes(params[:cop_question])
      flash[:notice] = 'COP Question was successfully updated.'
      redirect_to(admin_cop_questions_path)
    else
      render :action => "edit"
    end
  end

  def destroy
    @cop_question = CopQuestion.find(params[:id])
    @cop_question.destroy
    redirect_to(admin_cop_questions_path)
  end
end
