ThinkingSphinx::Index.define :organization,
  with: :active_record, name: :organization do
  indexes name, :sortable => true
  has country(:id), :as => :country_id, :facet => true
  has country(:name), :as => :country_name, :facet => true
  has organization_type(:type_property), :as => :business, :facet => true
  has organization_type(:id), :as => :organization_type_id, :facet => true
  has sector(:id), :as => :sector_id, :facet => true
  has sector(:name), :as => :sector_name, :facet => true
  has listing_status(:id), :as => :listing_status_id, :facet => true
  has listing_status(:name), :as => :listing_status_name, :facet => true
  # NOTE: This used to have :facet => true, but it broke search in production, and *only* in production - I don't know why, but I do know that this fixes it
  has "CRC32(cop_state)", :as => :cop_state, :type => :integer
  has joined_on, :facet => true
  has delisted_on, :facet => true
  has is_ft_500, :facet => true
  has state, active, participant
  # set_property :delta => true # TODO: Switch this to :delayed once we have DJ working
  set_property :enable_star => true
  set_property :min_prefix_len => 4
end

ThinkingSphinx::Index.define :organization,
  with: :active_record, name: :participant_search do

  indexes name, sortable: true
  has country(:id),           as: :country_id,            facet: true
  has organization_type(:id), as: :organization_type_id,  facet: true
  has sector(:id),            as: :sector_id,             facet: true
  has "CRC32(cop_state)",     as: :cop_state,             facet: true,   type: :integer
  has initiatives(:id),       as: :initiative_ids,        facet: true,   multi: true

  set_property :enable_star => true
  set_property :min_prefix_len => 4
end
