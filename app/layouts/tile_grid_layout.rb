class TileGridLayout < UNGC::Layout
  extend UNGC::Layout::Macros
  has_one_container!

  label 'Tile Grid'
  layout :tile_grid

  has_meta_tags!

  has_hero! do
    field :show_section_nav,  type: :boolean, default: false
  end
end

