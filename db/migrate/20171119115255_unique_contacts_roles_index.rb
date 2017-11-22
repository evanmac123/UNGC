class UniqueContactsRolesIndex < ActiveRecord::Migration
  def up
    change_column :contacts_roles, :contact_id, :integer, null: false
    change_column :contacts_roles, :role_id, :integer, null: false

    transaction do # Delete orphans before applying foreign key
      execute <<-SQL
        DELETE contacts_roles
        FROM contacts_roles
          LEFT OUTER JOIN roles ON roles.id = contacts_roles.role_id
        WHERE roles.id IS NULL
      SQL

      execute <<-SQL
        DELETE contacts_roles
        FROM contacts_roles
          LEFT OUTER JOIN contacts ON contacts.id = contacts_roles.contact_id
        WHERE contacts.id IS NULL
      SQL

    end

    add_foreign_key :contacts_roles, :contacts, on_delete: :cascade
    add_foreign_key :contacts_roles, :roles, on_delete: :cascade

    duplicates = ContactsRole
        .select(:contact_id, :role_id)
        .group(:contact_id, :role_id)
        .having('count(*) > 1')

    transaction do
      duplicates.each do |cr|
        # AR doesn't know how to delete these duplicates
        execute "delete from contacts_roles where contact_id=#{cr.contact_id} and role_id=#{cr.role.id}"
        execute "insert into contacts_roles (contact_id, role_id) values (#{cr.contact_id}, #{cr.role.id})"

        ContactsRole.includes(:role).where(name: 'xxxx').to_sql
      end
    end

    add_index :contacts_roles, [:contact_id, :role_id], unique: true, name: :contacts_roles_idx_pk
    remove_index :contacts_roles, name: :index_contacts_roles_on_contact_id
  end

  def down
    change_column :contacts_roles, :contact_id, :integer, null: true
    change_column :contacts_roles, :role_id, :integer, null: true

    remove_foreign_key :contacts_roles, :contacts
    remove_foreign_key :contacts_roles, :roles

    add_index :contacts_roles, :contact_id, name: :index_contacts_roles_on_contact_id
    remove_index :contacts_roles, name: :contacts_roles_idx_pk
  end
end
