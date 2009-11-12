class CopFile < ActiveRecord::Base
  validates_presence_of :name
  belongs_to :communication_on_progress, :foreign_key => :cop_id

  has_attached_file :attachment
end
