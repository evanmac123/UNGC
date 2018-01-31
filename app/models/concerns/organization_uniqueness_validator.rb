class OrganizationUniquenessValidator < ActiveModel::Validator
  def validate(record)
    ci_search_clause = DbConnectionHelper.backend == :mysql ?
        'organizations.name = :name' :
        'fold_ascii(organizations.name) = fold_ascii(:name)'

    base = Organization.where(ci_search_clause, name: record.name)
    base = base.where('id != :id', id: record.id) if record.persisted?
    record.errors.add(:name, "has already been used by another organization") \
        if record.name_changed? && base.exists?
  end
end