# == Schema Information
#
# Table name: igloo_users
#
#  id         :integer          not null, primary key
#  contact_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class IglooUser < ActiveRecord::Base
  belongs_to :contact
end
