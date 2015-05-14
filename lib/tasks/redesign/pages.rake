namespace :redesign do

  desc "create stub pages to fill out the site map"
  task create_sitemap: :environment do
    raise "Must be run from the development environment" unless Rails.env.development?
    Tagging.where.not(redesign_container_id: nil).delete_all
    Redesign::Container.delete_all
    root = Node.new

    ancestors = []
    previous_depth = -1
    previous_page = nil
    output = visit page_data.first do |page, depth|
      case
      when depth > previous_depth && previous_page.present?
        ancestors.push previous_page
      when depth < previous_depth
        (previous_depth - depth).times do
          ancestors.pop
        end
      end

      path = ancestors.map {|p|
        scrub(p[:slug] || p[:path])
      }
      page_slug = scrub(page[:slug] || page[:path])
      url = (path + [page_slug]).join("/")

      page[:slug] = Redesign::Container.normalize_slug(page_slug)
      page[:url] = url

      previous_page = page
      previous_depth = depth

      if page[:template].present?
        container = Redesign::Container.create!(
          layout: page[:template].downcase,
          slug: page[:slug],
          path: page[:url]
        )

        parent = ancestors.last

        if parent.present?
          container.update_column(:parent_container_id, parent[:id])
        end

        page[:id] = container.id

        if page[:sort_order_position]
          container.update_attribute :sort_order_position, page[:sort_order_position]
        end

      end

      puts page[:slug]
      page
    end

    Redesign::Container.
      find_each(&:cache_child_containers_count)

    File.open('pages-with-slugs.json', 'w+') do |f|
      f.write(output.to_json)
    end
  end

  task update_sitemap: :environment do
    #Tagging.where.not(redesign_container_id: nil).delete_all
    #Redesign::Container.delete_all

    ancestors = []
    previous_depth = -1
    previous_page = nil
    output = visit page_data.first do |page, depth|
      case
      when depth > previous_depth && previous_page.present?
        ancestors.push previous_page
      when depth < previous_depth
        (previous_depth - depth).times do
          ancestors.pop
        end
      end

      path = ancestors.map {|p|
        scrub(p[:slug] || p[:path])
      }
      page_slug = scrub(page[:slug] || page[:path])
      url = (path + [page_slug]).join("/")

      page[:slug] = Redesign::Container.normalize_slug(page_slug)
      if url.blank?
        url = '/'
      end
      page[:url] = url

      previous_page = page
      previous_depth = depth

      if page[:template].present?
        oldpath = page[:old_path]
        container = nil
        if oldpath && container = Redesign::Container.find_by(path: oldpath)
        else
          container = Redesign::Container.find_or_initialize_by(path: page[:url])
        end
        container.path = page[:url]
        container.layout = page[:template].downcase
        container.slug = page[:slug]
        container.save

        parent = ancestors.last

        if parent.present?
          container.update_column(:parent_container_id, parent[:id])
        end

        page[:id] = container.id

        if page[:sort_order_position]
          container.update_attribute :sort_order_position, page[:sort_order_position]
        end

        if page[:delete]
          Tagging.where(redesign_container_id: container.id).each(&:destroy)
          container.destroy
        end

      end

      puts page[:slug]
      page
    end

    Redesign::Container.
      find_each(&:cache_child_containers_count)

    File.open('pages-with-slugs.json', 'w+') do |f|
      f.write(output.to_json)
    end
  end

  def scrub(input)
    input.gsub(' ', '-').gsub(/[^a-z\d-]+/i, '').downcase.gsub('--', '-')
  end

  desc "show the basic site map"
  task :tree do
    walk page_data do |page, depth|
      title = page[:path]
      layout = page[:template]
      indent = depth.times.map{"\t"}.join
      puts "#{indent}#{title} (#{layout})"
    end
  end

  desc "create the basic site map"
  task :tree2 do
    root = Node.new
    root.children = tree(page_data, root)
    ap root
  end

  desc "show the unique layouts"
  task :layouts do
    layouts = walk page_data do |page, depth|
      page[:template]
    end
    puts layouts.flatten.uniq
  end

  desc "show slug paths"
  task :slugs do
    stack = []
    last_depth = 0
    last_layout = nil
    walk page_data do |page, depth|
      case
      when depth > last_depth
        stack << last_layout
      when depth < last_depth
        stack.pop
      end
      last_layout = page[:path].downcase.gsub(' ', '_').underscore
      last_depth = depth

      puts stack.join ","
    end
  end

  private

  def walk(pages, depth = 0, &block)
    pages.map do |page|
      page = block.call(page, depth)
      child_values = if page.has_key? :children
        walk page[:children], depth+1, &block
      else
        []
      end
      [page, child_values]
    end
  end

  def tree(pages, parent_node)
    pages.map do |page|
      node = Node.new
      node.title = page[:path]
      node.depth = parent_node.depth + 1
      node.parent = parent_node
      if page.has_key? :children
        node.children = tree(page[:children], node)
      end
      node
    end
  end

  def visit(node, depth=0, &block)
    return if node.nil?

    node = block.call(node, depth)
    if node.has_key? :children
      node[:children].each_with_index do |child, i|
        node[:children][i] = visit(child, depth + 1, &block)
      end
    end
    node
  end

  def page_data
    data = JSON.parse(File.read('./lib/tasks/redesign/new_pages.json')).deep_symbolize_keys
    [data]
  end

  class Node
    attr_accessor :title, :depth, :parent, :children

    def initialize
      @title = ""
      @depth = 0
      @children = []
    end

  end

end
