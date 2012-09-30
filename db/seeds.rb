puts "Seeding data..."

# Create organization to contain Local Network Guest contacts

country = Country.find_by_name("United States of America")
country_id = country.nil? ? nil : country.id

organization_type = OrganizationType.find_by_name("NGO Global")
organization_type_id = organization_type.nil? ? nil : organization_type.id

params = { :name                 => DEFAULTS[:local_network_guest_name],
           :employees            => 0,
           :country_id           => country_id,
           :organization_type_id => organization_type_id,
           :participant          => false,
           :active               => false,
           :state                => Organization::STATE_APPROVED }

Organization.destroy_all(params)
organization = Organization.find_or_create_by_name(params)

# Create Local Network Guest with login

test_email = 'test.user@testing.com'
params = { :organization_id => organization.id,
           :prefix          => 'Local Network',
           :first_name      => 'Guest',
           :last_name       => 'User',
           :email           =>  test_email,
           :job_title       => 'Guest User',
           :phone           => 'n/a',
           :address         => 'n/a',
           :city            => 'n/a',
           :country_id      => organization.country_id,
           :login           => 'gclnguest',
           :password        => 'gclnguest' }

Contact.destroy_all(:email => test_email)
contact = Contact.create(params)

# Create Local Network Guest role

params = { :name => 'Local Network Guest', :description => 'Resricted access to view Local Network information' }
Role.destroy_all(params)
role = Role.create(params)
contact.roles << role