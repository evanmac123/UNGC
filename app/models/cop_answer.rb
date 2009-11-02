class CopAnswer < ActiveRecord::Base
  belongs_to :communication_on_progress
  belongs_to :cop_attribute
end
