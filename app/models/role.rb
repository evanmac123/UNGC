# == Schema Information
#
# Table name: roles
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  old_id     :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class Role < ActiveRecord::Base
  validates_presence_of :name
  has_and_belongs_to_many :contacts, :join_table => "contacts_roles"
  
  def self.network_contact
    find :all, :conditions => ["old_id IN (?)", [5,12]] # FIXME: Update this to newer ids, text, constant??
  end
end
