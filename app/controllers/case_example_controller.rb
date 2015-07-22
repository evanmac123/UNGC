class CaseExampleController < Redesign::ApplicationController

  def new
    @case_example = CaseExampleForm.new
    @page = load_page
  end

  def create
    @case_example = CaseExampleForm.new(case_example_params)
    @page = load_page

    if @case_example.submit
      redirect_to case_example_path, notice: 'Thank you for sharing your successful case example.'
    else
      render :new
    end
  end

  private
    def load_page
      set_current_container_by_path '/take-action/action/share-story'
      ArticleFormPage.new(current_container, current_payload_data)
    end

    def case_example_params
      params.require(:case_example_form).permit(
        :company,
        :country_id,
        :is_participant,
        :file,
        :magic,
        :sector_ids => []
      )
    end
end
