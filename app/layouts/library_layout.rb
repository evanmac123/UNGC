class LibraryLayout < UNGC::Layout
  extend UNGC::Layout::Macros
  has_one_container!

  label 'Library'
  layout :library

  has_meta_tags!

  has_hero! do
    field :show_library_search,  type: :boolean, default: true
  end

  scope :featured, array: true, size: 12 do
    field :resource_id, type: :number, required: true
  end
end
