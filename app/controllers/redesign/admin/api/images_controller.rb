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
      render_json image.errors, status: 422
    end
  end

  def update
    image = UploadedImage.find(params[:id])

    if image.update_attributes(image_params)
      render nothing: true, status: 204
    else
      render_json image.errors, status: 422
    end
  end

  def index
    render json: { images: scoped_images.map(&method(:serialize)), meta: {total_pages: scoped_images.total_pages} }
  end

  def show
    image = UploadedImage.find(params[:id])
    render json: { image: serialize(image) }
  end

  def destroy
    image = UploadedImage.find(params[:id])
    image.destroy
    render nothing: true, status: 204
  end

  private

  def serialize(image)
    {
      id: image.id,
      url: image.url,
      filename: image.filename,
      licensing: image.licensing,
      has_licensing: image.has_licensing
    }
  end

  def image_params
    params.fetch(:image).permit(:url, :filename, :has_licensing).tap do |whitelisted|
      whitelisted[:licensing] = params[:image][:licensing]
    end
  end

  def scoped_images
    @scoped ||= begin
                  scoped = UploadedImage.order(created_at: :desc)
                  if params[:query]
                    scoped = scoped.where('filename LIKE ?', "%#{params[:query]}%")
                  end
                  scoped.paginate({page: params[:page], per_page: params[:per_page]})
                end
  end

end
