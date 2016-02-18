class SdgPioneerController < ApplicationController

  def index
    set_current_container_by_default_path
    @page = HighlightPage.new(current_container, current_payload_data)
  end

end
