# == Schema Information
#
# Table name: uploaded_files
#
#  id                             :integer          not null, primary key
#  attachable_id                  :integer
#  attachable_type                :string(255)
#  created_at                     :datetime
#  updated_at                     :datetime
#  attachment_file_name           :string(255)
#  attachment_file_size           :integer
#  attachment_content_type        :string(255)
#  attachment_updated_at          :datetime
#  attachment_unmodified_filename :string(255)
#

Paperclip.interpolates(:attachable_type) { |attachment, style|
  raise "Could not determine attachable_type" unless attachment.try(:instance).try(:attachable_type).present?
  attachment.instance.attachable_type
}

class UploadedFile < ActiveRecord::Base
  belongs_to :attachable, :polymorphic => true

  has_attached_file :attachment,
    :url => "/system/:attachment/:attachable_type/:id/:style/:filename"

  alias_method :original_attachment=, :attachment=

  after_save    :update_indexed_fields_on_parent
  after_destroy :update_indexed_fields_on_parent

  def attachment=(file)
    self.original_attachment = file

    if file.respond_to?(:original_filename)
      self.attachment_unmodified_filename = file.original_filename
    end
  end

  def attachment_unmodified_filename
    self[:attachment_unmodified_filename] || self[:attachment_file_name]
  end

  def update_indexed_fields_on_parent
    if attachable.respond_to?(:update_indexed_fields)
      attachable.update_indexed_fields
    end
  end
end
