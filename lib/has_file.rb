module HasFile
  def self.included(klass)
    klass.class_eval do
      has_one :attachment, :class_name => 'UploadedFile', :as => :attachable
      validates_presence_of :file
    end
  end

  def file
    attachment
  end

  def file=(file)
    build_attachment(:uploaded_data => file)
  end
end

