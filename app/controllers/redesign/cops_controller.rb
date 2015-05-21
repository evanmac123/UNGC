class Redesign::CopsController < Redesign::ApplicationController

  def index
    set_current_container_by_path('/participation/report/cop/create-and-submit')

    @page = page_for_container(current_container).new(
      current_container,
      current_payload_data
    )

    render("/redesign/static/" + current_container.layout)
  end

  def active
    set_current_container_by_path('/participation/report/cop/create-and-submit/active')
    @page = CopListPage.new(current_container, current_payload_data)
  end

  def advanced
    set_current_container_by_path('/participation/report/cop/create-and-submit/advanced')
    @page = CopListPage.new(current_container, current_payload_data)
  end

  def expelled
    set_current_container_by_path('/participation/report/cop/create-and-submit/expelled')
    @page = CopListPage.new(current_container, current_payload_data)
  end

  def learner
    set_current_container_by_path('/participation/report/cop/create-and-submit/learner')
    @page = CopListPage.new(current_container, current_payload_data)
  end

  def non_communicating
    set_current_container_by_path('/participation/report/cop/create-and-submit/non_communicating')
    @page = CopListPage.new(current_container, current_payload_data)
  end

  def submitted_coe
    set_current_container_by_path('/participation/report/coe/create-and-submit/submitted_coe')
    @page = CopListPage.new(current_container, current_payload_data)
  end

  def show
    @page = CopDetailPage.new(current_container)

    if load_communication_on_progress
      redirect_mismatched_differentiation_urls
      determine_navigation
      @communication = CommunicationPresenter.create(@communication_on_progress, current_contact)
    else
      redirect_to DEFAULTS[:cop_path] # FIXME: Should redirect to search?
    end
  end

  # XXX this is only in the old system?
  def feed
    @cops_for_feed = CommunicationOnProgress.approved.for_feed

    respond_to do |format|
      format.atom { render :layout => false }
    end
  end

  private

    def load_communication_on_progress
      @communication_on_progress = find_cop_by_id || find_cop_by_cop_and_org
    end

    def find_cop_by_id
      CommunicationOnProgress.find_by_id(params[:id])
    end

    def find_cop_by_cop_and_org
      @organization = Organization.find_by_param(params[:organization])
      @organization.communication_on_progresses.find_by_param(params[:cop]) if @organization
    end

    def redirect_mismatched_differentiation_urls
      nav = params[:navigation]
      differentiation = @communication_on_progress.differentiation
      if nav.present? &&
          differentiation.present? &&
          nav != differentiation
        redirect_to cop_detail_with_nav_url(differentiation, @communication_on_progress.id),
          status: :moved_permanently
      end
    end

end
