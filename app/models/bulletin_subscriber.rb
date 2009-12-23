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
  validates_format_of :email, :with => /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/, :on => :create, :message => "is not a valid emai "
end