class CopsController < ApplicationController

  def index
    set_current_container_by_path('/participation/report/cop/create-and-submit')

    @page = page_for_container(current_container).new(
      current_container,
      current_payload_data
    )

    render "static/#{current_container.layout}"
  end

  def active
    set_current_container_by_path('/participation/report/cop/create-and-submit/active')
    @page = CopListPage.new(current_container, current_payload_data)
    @cops = CommunicationOnProgress.summary.active.paginate(pagination_params)
  end

  def advanced
    set_current_container_by_path('/participation/report/cop/create-and-submit/advanced')
    @page = CopListPage.new(current_container, current_payload_data)
    @cops = CommunicationOnProgress.summary.advanced.paginate(pagination_params)
  end

  def expelled
    set_current_container_by_path('/participation/report/cop/create-and-submit/expelled')
    @page = CopListPage.new(current_container, current_payload_data)
    @organizations = Organization.participants
      .summary
      .expelled
      .paginate(pagination_params)
  end

  def learner
    set_current_container_by_path('/participation/report/cop/create-and-submit/learner')
    @page = CopListPage.new(current_container, current_payload_data)
    @cops = CommunicationOnProgress.summary.learner.paginate(pagination_params)
  end

  def non_communicating
    set_current_container_by_path('/participation/report/cop/create-and-submit/non-communicating')
    @page = CopListPage.new(current_container, current_payload_data)

    @organizations = Organization.participants
      .summary
      .companies_and_smes
      .noncommunicating
      .paginate(pagination_params)
  end

  def submitted_coe
    set_current_container_by_path('/participation/report/coe/create-and-submit/submitted-coe')
    @page = CopListPage.new(current_container, current_payload_data)
    @cops = CommunicationOnProgress.summary.coes.paginate(pagination_params)
  end

  def show
    set_current_container_by_path('/participation/report')
    cop = CommunicationOnProgress.
      includes(cop_answers: [:cop_attribute], cop_files: [:language]).
      find(params[:id])
    @communication = CommunicationPresenter.create(cop, current_contact)
    @page = CopDetailPage.new(current_container, @communication)
  end

  def feed
    @cops_for_feed = CommunicationOnProgress.approved.for_feed.map do |cop|
      CommunicationPresenter.create(cop, current_contact)
    end

    respond_to do |format|
      format.atom { render :layout => false }
    end
  end

  def pagination_params
    {
      page: params.fetch(:page, 1),
      per_page: params.fetch(:per_page, 10),
    }
  end
end
