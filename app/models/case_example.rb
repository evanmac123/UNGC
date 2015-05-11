class CaseExample < ActiveRecord::Base
  belongs_to :country
  has_many :taggings
  has_many :sectors, through: :taggings
  has_attached_file :file,
    url: '/system/:class/:attachment/:id/:filename'

  validates :company, :country_id, :file, presence: true
  validates :is_participant, :inclusion => {:in => [true, false], message: "can't be blank"}

  validates_attachment_content_type :file, content_type: [
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'text/plain'
  ]

end
