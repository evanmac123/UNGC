module HasFile
  def self.included(klass)
    klass.class_eval do
      has_one :attachment, :class_name => 'UploadedFile', :as => :attachable, :dependent => :destroy
      validates_presence_of :file, :message => 'must be uploaded'
    end
  end

  def file
    attachment
  end

  def file=(file)
    attachment.destroy if attachment
    self.attachment = UploadedFile.new(:uploaded_data => file)
  end
end