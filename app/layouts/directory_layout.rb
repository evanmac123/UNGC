class DirectoryLayout < UNGC::Layout
  extend UNGC::Layout::Macros
  has_one_container!

  label 'Directory'
  layout :directory

  has_meta_tags!

  has_hero!

end
