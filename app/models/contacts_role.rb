class ContactsRole < ActiveRecord::Base
  belongs_to :contact, inverse_of: :contacts_roles
  belongs_to :role, inverse_of: :contacts_roles
end
