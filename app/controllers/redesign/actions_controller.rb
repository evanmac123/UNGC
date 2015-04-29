class Redesign::ActionsController < Redesign::ApplicationController
  def index
    set_current_container :tile_grid, '/take-action/what-you-can-do'
    form= Redesign::WhatYouCanDoForm.new(params[:page])
    @page = WhatYouCanDoPage.new(current_container, current_payload_data, form.results)
  end
end
