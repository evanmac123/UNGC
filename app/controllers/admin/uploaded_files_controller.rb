class Admin::UploadedFilesController < AdminController
  def show
    file = UploadedFile.find(params[:id])
    send_data File.read(file.attachment.path, :encoding => "ASCII-8BIT"), :type => "#{file.attachment.content_type}; charset=ASCII-8BIT", :disposition => 'inline'
  end
end

