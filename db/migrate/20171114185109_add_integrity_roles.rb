class AddIntegrityRoles < ActiveRecord::Migration
  def up
    Role.find_or_create_by!(name: Role::FILTERS[:integrity_team_member]) do |role|
      role.description = 'Part of the Integrity Team.'
    end

    integrity_manager = Role.find_or_create_by!(name: Role::FILTERS[:integrity_manager]) do |role|
      role.description = 'Integrity Team member authorized to render decisions.'
    end

    # Assign role to integrity managers
    %w[byrne@unglobalcompact.org bombis@unglobalcompact.org].each do |email|
      mgr = Contact.find_by!(email: email)
      mgr.roles << integrity_manager
      mgr.save!
    end
  end

  def down

    team_member = Role.find_by(name: Role::FILTERS[:integrity_team_member])
    integrity_manager = Role.find_by(name: Role::FILTERS[:integrity_manager])

    execute "DELETE FROM contacts_roles WHERE role_id in (#{team_member&.id}, #{integrity_manager&.id})"

    Role.find_by(name: Role::FILTERS[:integrity_manager])&.destroy
    Role.find_by(name: Role::FILTERS[:integrity_team_member])&.destroy
  end
end


def self.integrity_team_member
  @_integrity_team_member ||= find_by(name: FILTERS[:integrity_team_member])
end

def self.integrity_manager
  @_integrity_manager ||= find_by(name: FILTERS[:integrity_manager])
end
