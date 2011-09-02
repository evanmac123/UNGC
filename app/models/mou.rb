class MOU < ActiveRecord::Base
  belongs_to :local_network
  has_one :attachment, :class_name => 'UploadedFile', :as => :attachable

  validates_inclusion_of :year, :in => 2000..Date.today.year, :allow_nil => false
  validates_presence_of :file

  def file
    attachment
  end

  def file=(file)
    build_attachment(:uploaded_data => file)
  end
end

