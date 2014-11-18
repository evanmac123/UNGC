# == Schema Information
#
# Table name: page_groups
#
#  id                    :integer          not null, primary key
#  name                  :string(255)
#  display_in_navigation :boolean
#  html_code             :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  position              :integer
#  path_stub             :string(255)
#

class PageGroup < ActiveRecord::Base
  has_many :children, -> { where parent_id: nil }, :class_name => 'Page', :foreign_key => :group_id
  has_many :visible_children,
    -> { where(approval: 'approved', display_in_navigation: true, parent_id: nil)
        .order('position ASC') },
    :class_name  => 'Page',
    :foreign_key => :group_id
  has_many :approved_children,
    -> { where(approval: 'approved', parent_id: nil)
        .order('position ASC') },
    :class_name  => 'Page',
    :foreign_key => :group_id

  scope :for_navigation, -> { includes(:visible_children).where("page_groups.display_in_navigation = ?", true).order("page_groups.position ASC") }

  default_scope { order('page_groups.position ASC') }

  before_create :derive_position
  after_destroy :destroy_children

  def derive_position
    unless position
      max = self.class.find_by_sql('select MAX(position) as position from page_groups').first.position rescue 0
      self.position = (max || 0) + 1
    end
  end

  def destroy_children
    children.each { |page| page.destroy }
  end

  def link_to_first_child
    visible_children.first.try(:path) || ''
  end

  def path
    link_to_first_child
  end

  def title
    name
  end

  def title=(string)
    self.name = string
  end

  def self.import_tree(*args)
    TreeImporter.import_tree(*args)
  end

  def leaves
    Page.find_leaves_for(id)
  end

end
