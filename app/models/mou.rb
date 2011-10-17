class MOU < ActiveRecord::Base
  include HasFile
  belongs_to :local_network

  TYPES = { :in_review => 'In review', :accepted => 'Accepted' }

  before_create :set_type
  
  default_scope :order => 'year DESC'

  def self.local_network_model_type
    :network_management
  end

  def type_name
    TYPES[mou_type.try(:to_sym)]
  end

  def mou_type_for_select_field
    mou_type.try(:to_sym)
  end

  def readable_error_messages
    error_messages = []
    errors.each do |error|
      case error
        when 'file'
          error_messages << 'Choose a file to upload'
       end
    end
    error_messages
  end

  private
  
    def set_type
      self.mou_type = :in_review.to_s
    end

end

