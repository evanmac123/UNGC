# == Schema Information
#
# Table name: cop_files
#
#  id                      :integer          not null, primary key
#  cop_id                  :integer
#  attachment_file_name    :string(255)
#  attachment_content_type :string(255)
#  attachment_file_size    :integer
#  attachment_updated_at   :datetime
#  created_at              :datetime
#  updated_at              :datetime
#  attachment_type         :string(255)
#  language_id             :integer
#

class CopFile < ActiveRecord::Base
  validates_presence_of :attachment_type, :language
  belongs_to :communication_on_progress, :foreign_key => :cop_id
  belongs_to :language

  has_attached_file :attachment
  validates_attachment_presence :attachment

  TYPES = {:grace_letter          => 'grace_letter',
           :cop                   => 'cop',
           :cop_with_stakeholders => 'cop_with_stakeholders',
           :web_cop               => 'web_cop',
           :support_statement     => 'support_statement'}

  def self.all_files
    includes([{:communication_on_progress => [:organization]}, :language ])
      .where(['language_id IS NOT NULL'])
      .order("cop_files.created_at DESC")
  end

  def language_name
    language.try(:name)
  end

  def differentiation_name
    communication_on_progress.try(:differentiation)
  end

end
