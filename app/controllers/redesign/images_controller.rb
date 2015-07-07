class Redesign::ImagesController < Redesign::ApplicationController
  def index
    @images = UploadedImage.
      where(has_licensing: true).
      order('updated_at asc').
      paginate(page: page, per_page: 10)
  end

  private

  def page
    params.fetch(:page, 1).try(:to_i)
  end

end
