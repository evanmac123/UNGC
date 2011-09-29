class MOU < ActiveRecord::Base
  include HasFile
  belongs_to :local_network

  def local_network_model_type
    :network_management
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

end

