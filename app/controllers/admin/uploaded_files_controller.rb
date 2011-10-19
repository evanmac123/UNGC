class Admin::UploadedFilesController < AdminController
  def show
    file = UploadedFile.find(params[:id])
    attachment = file.attachment
    send_file attachment.path, :type => attachment.content_type, :filename => attachment.original_filename
  end
end

