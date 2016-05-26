# == Schema Information
#
# Table name: case_examples
#
#  id                :integer          not null, primary key
#  company           :string(255)
#  country_id        :integer
#  is_participant    :boolean
#  file_file_name    :string(255)
#  file_content_type :string(255)
#  file_file_size    :integer
#  file_updated_at   :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class CaseExample < ActiveRecord::Base
  belongs_to :country
  has_many :taggings, dependent: :destroy
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
