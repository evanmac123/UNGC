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
    serialized = scoped_images.map do |i|
      {id: i.id, url: i.url, filename: i.filename }
    end
    render json: { images: serialized, meta: {total_pages: scoped_images.total_pages} }
  end

  def destroy
    image = UploadedImage.find(params[:id])
    image.destroy
    render nothing: true, status: 204
  end

  private

  def image_params
    params.fetch(:image).permit(:url, :filename)
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

