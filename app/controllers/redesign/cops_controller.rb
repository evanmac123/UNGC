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
    set_current_container_by_path('/participation/report/cop/create-and-submit/non-communicating')
    @page = CopListPage.new(current_container, current_payload_data)
  end

  def submitted_coe
    set_current_container_by_path('/participation/report/coe/create-and-submit/submitted-coe')
    @page = CopListPage.new(current_container, current_payload_data)
  end

  def show
    @page = CopDetailPage.new(current_container)
    cop = CommunicationOnProgress.find_by_id(params[:id])
    @communication = CommunicationPresenter.create(cop, current_contact)
  end

  # XXX this is only in the old system?
  def feed
    @cops_for_feed = CommunicationOnProgress.approved.for_feed

    respond_to do |format|
      format.atom { render :layout => false }
    end
  end
end
