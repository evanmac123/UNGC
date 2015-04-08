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
    image = UploadedImage.create(
      url: params[:url]
    )

    if image.valid?
      render nothing: true, status: 201
    else
      render_json image.error, status: 422
    end
  end

end

