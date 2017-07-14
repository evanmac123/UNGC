module Crm
  class Owner < ActiveRecord::Base
    belongs_to :contact

    DEFAULT_OWNER_ID = '005A0000004KjLy'.freeze

    def name
      contact.try!(:name)
    end

  end
end
