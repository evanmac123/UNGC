class Redesign::IssuesController < Redesign::ApplicationController
  def index
    set_current_container_by_path '/about-gc/our-work/all'
    form= Redesign::AllOurWorkForm.new(params[:page])
    @page = AllOurWorkPage.new(current_container, current_payload_data, form.results)
  end
end
