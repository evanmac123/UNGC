class PublishedWebpages < SimpleReport
  def records
    sections.flat_map do |section|
      pages_in_section(section)
    end
  end

  def headers
    [ 'Page ID',
      'Path',
      'Title',
      'Main Section',
      'Main Section Order',
      'Parent Section',
      'Visible in Navigation?',
      'Order in Navigation',
      'Number of Versions',
      'Last Updated on'
    ]
  end

  def row(record)
    [
      record.id,
      record.path,
      record.title,
      record.main_section,
      record.main_section_order,
      record.parent_section,
      record.visible_in_navigation?,
      record.position,
      record.version_number,
      record.approved_at
    ]
  end

  private

  # copied and adapted from app/helpers/admin/pages_helper.rb
  def sections
    homes_children = Page.approved.where(parent_id: nil, group_id: nil).order('position ASC').all
    @home = OpenStruct.new(id: 'home', title: 'Home', leaves: {nil => homes_children})
    [@home] + PageGroup.all
  end

  def pages_in_section(section)
    leaves   = section.leaves || {}
    children = leaves[nil] || []
    children.select(&:approved?).flat_map do |c|
      child_pages(c, leaves)
    end
  end

  def child_pages(page, leaves)
    children = leaves[page.approved_id] || []
    [Decorator.new(page)] + children.select(&:approved?).flat_map do |c|
      child_pages(c, leaves)
    end
  end

  class Decorator < SimpleDelegator

    def main_section
      section.try(:title) || "Home"
    end

    def main_section_order
      section.try(:position)
    end

    def parent_section
      parent.try(:title)
    end

    def visible_in_navigation?
      display_in_navigation ? 'Yes' : 'No'
    end

  end

end
