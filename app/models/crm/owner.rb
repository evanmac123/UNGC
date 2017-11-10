# == Schema Information
#
# Table name: crm_owners
#
#  id         :integer          not null, primary key
#  contact_id :integer          not null
#  crm_id     :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

module Crm
  class Owner < ActiveRecord::Base
    belongs_to :contact

    DEFAULT_OWNER_ID = '005A0000004KjLy'.freeze

    def name
      contact.try!(:name)
    end

  end
end
