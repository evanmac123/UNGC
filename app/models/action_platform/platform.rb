# == Schema Information
#
# Table name: action_platform_platforms
#
#  id          :integer          not null, primary key
#  name        :string(255)      not null
#  description :text(65535)      not null
#  status      :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  slug        :string(32)       not null
#

class ActionPlatform::Platform < ActiveRecord::Base
  has_many :subscriptions, dependent: :destroy

  validates :name, presence: true, length: { in: 1..250 }
  validates :description, presence: true
  validates :slug, presence: true, length: { in: 1..32 }

end
