class Redesign::Admin::Api::ImagesController < Redesign::Admin::ApiController

  def signed_url
    uploader = S3Uploader.new(params[:filename])
    if uploader.valid?
      render :json => { valid: true, signed_url: uploader.url, mime: uploader.mime, base_url: uploader.base_url}
    else
      render :json => { valid: false }, status: :unprocessable_entity
    end
  end

  def create
    image = UploadedImage.create(image_params)

    if image.valid?
      render nothing: true, status: 201
    else
      render_json image.error, status: 422
    end
  end

  def index
    images = UploadedImage.order(created_at: :desc).paginate({page: params[:page], per_page: params[:per_page]})
    serialized = images.map { |i| {id: i.id, url: i.url, filename: i.filename }}
    render json: { images: serialized, meta: {total_pages: images.total_pages} }
  end

  private

  def image_params
    params.fetch(:image).permit(:url, :filename)
  end

end
