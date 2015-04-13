class LibraryLayout < UNGC::Layout
  extend UNGC::Layout::Macros
  has_one_container!

  label 'Library'
  layout :library

  has_meta_tags!

  scope :featured, array: true, size: 9 do
    field :resource_id, type: :number, required: true
  end
end
