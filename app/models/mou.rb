class MOU < ActiveRecord::Base
  belongs_to :local_network
  has_many :attachments, :class_name => 'UploadedFile', :as => :attachable

  validates_inclusion_of :year, :in => 2000..Date.today.year, :allow_nil => false
  validates_presence_of :file

  def file
    attachments.first
  end

  def file=(file)
    attachments.build(:uploaded_data => file)
  end
end

