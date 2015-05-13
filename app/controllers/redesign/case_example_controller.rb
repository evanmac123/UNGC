class Redesign::CaseExampleController < Redesign::ApplicationController

  def new
    @case_example = Redesign::CaseExampleForm.new
    @page = CaseExamplePage.new(current_container)
  end

  def create
    @case_example = Redesign::CaseExampleForm.new(case_example_params)
    @page = CaseExamplePage.new(current_container)

    if @case_example.submit
      redirect_to redesign_case_example_path, notice: 'Thank you for sharing your successful case example.'
    else
      render :new
    end
  end

  private
    def case_example_params
      params.require(:redesign_case_example_form).permit(
        :company,
        :country_id,
        :is_participant,
        :file,
        :sector_ids => []
      )
    end
end
