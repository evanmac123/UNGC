class NonBusinessOrganizationDetail < ActiveRecord::Base
  has_one :organization, as: :organization_detail
end
