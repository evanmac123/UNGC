# == Schema Information
#
# Table name: contacts_roles
#
#  contact_id :integer          not null
#  role_id    :integer          not null
#

class ContactsRole < ActiveRecord::Base
  belongs_to :contact, inverse_of: :contacts_roles
  belongs_to :role, inverse_of: :contacts_roles
end
