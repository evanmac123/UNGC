# == Schema Information
#
# Table name: bulletin_subscribers
#
#  id                :integer(4)      not null, primary key
#  first_name        :string(255)
#  last_name         :string(255)
#  organization_name :string(255)
#  email             :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#

class BulletinSubscriber < ActiveRecord::Base
  validates_presence_of :email
end
