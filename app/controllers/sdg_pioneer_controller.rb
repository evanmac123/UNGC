class SdgPioneerController < ApplicationController

  def index
    set_current_container_by_path("/sdgs/sdgpioneers")
    @page = HighlightPage.new(current_container, current_payload_data)
  end

end
