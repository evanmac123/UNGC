class Redesign::ActionsController < Redesign::ApplicationController
  def index
    set_current_container :tile_grid, '/take-action/what-you-can-do'
    results = Redesign::Container.action.includes(:public_payload)
    @page = WhatYouCanDoPage.new(current_container, current_payload_data, results)
  end
end
