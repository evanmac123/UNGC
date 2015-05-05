class Redesign::NetworksController < Redesign::ApplicationController
  def show
    name = params[:network]
    network = LocalNetwork.where("lower(name) = ?", name.downcase).first!
    @page = LocalNetworkPage.new(network)
  end

  # TODO handle these routes better, find a way to redirect to the catch all
  def africa_strategy
    set_current_container_by_path('/engage-locally/africa/africa-strategy')

    @page = page_for_container(current_container).new(
      current_container,
      current_payload_data
    )

    render("/redesign/static/" + current_container.layout)
  end

  def manage
    set_current_container_by_path('/engage-locally/manage')

    @page = page_for_container(current_container).new(
      current_container,
      current_payload_data
    )

    render("/redesign/static/" + current_container.layout)
  end

  def catch_all
    set_current_container_by_path('/engage-locally/manage/' + params[:path])

    @page = page_for_container(current_container).new(
      current_container,
      current_payload_data
    )

    render("/redesign/static/" + current_container.layout)
  end

  private

  def page_for_container(container)
    "#{container.layout}_page".classify.constantize
  end
end
