class Admin::CopQuestionsController < AdminController
  before_filter :no_organization_or_local_network_access
  before_filter :fetch_question, :only => [:destroy, :update, :edit]

  def index
    session[:year_filter] = params[:year]
    @cop_questions = questions.order(:position, :grouping, :year)
  end

  def new
    @cop_question = CopQuestion.new
    @cop_question.year = session[:year_filter]
  end

  def create
    @cop_question = CopQuestion.new(question_params)
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

  def questions
    case
    when year == 'no_year'
      CopQuestion.where(year: nil)
    when year.present?
      CopQuestion.where(year: year)
    else
      CopQuestion.all
    end
  end

  def year
    args = params.permit(:year)
    args[:year]
  end

  def question_params
    params.require(:cop_question).permit(
      :principle_area_id,
      :text,
      :position,
      :initiative_id,
      :grouping,
      :implementation,
      :year,
    )
  end

end
