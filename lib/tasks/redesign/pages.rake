namespace :redesign do

  desc "disable dragging for some pages"
  task disable_dragging: :environment do
    containers = %w{
    /
    /what-is-gc
    /what-is-gc/mission
    /what-is-gc/mission/principles
    /what-is-gc/mission/principles/principle-1
    /what-is-gc/mission/principles/principle-2
    /what-is-gc/mission/principles/principle-3
    /what-is-gc/mission/principles/principle-4
    /what-is-gc/mission/principles/principle-5
    /what-is-gc/mission/principles/principle-6
    /what-is-gc/mission/principles/principle-7
    /what-is-gc/mission/principles/principle-8
    /what-is-gc/mission/principles/principle-9
    /what-is-gc/mission/principles/principle-10
    /what-is-gc/our-work
    /what-is-gc/our-work/all
    /what-is-gc/participants
    /about
    /about/contact
    /copyright
    /engage-locally
    /engage-locally/about-local-networks
    /engage-locally/africa
    /engage-locally/asia
    /engage-locally/europe
    /engage-locally/latin-america
    /engage-locally/manage
    /engage-locally/mena
    /engage-locally/north-america
    /engage-locally/oceania
    /library
    /news
    /news/press-releases
    /news/bulletin
    /news/bulletin-confirmation
    /participation
    /participation/join
    /participation/join/application
    /participation/join/application/business
    /participation/join/application/non-business
    /participation/report
    /participation/report/cop
    /participation/report/cop/create-and-submit
    /participation/report/cop/create-and-submit/active
    /participation/report/cop/create-and-submit/advanced
    /participation/report/cop/create-and-submit/expelled
    /participation/report/cop/create-and-submit/learner
    /participation/report/cop/create-and-submit/non-communicating
    /participation/report/coe
    /participation/report/coe/create-and-submit
    /participation/report/coe/create-and-submit/submitted-coe
    /privacy-policy
    /take-action
    /take-action/action
    /take-action/action/case-example
    /take-action/events
    /welcome
    /welcome/academic
    /welcome/business
    /welcome/city
    /welcome/non-business
    }
    containers.each do |c|
      container = Container.find_by path: c
      container.update_attribute :draggable, false
    end
  end

  desc "create stub pages to fill out the site map"
  task create_sitemap: :environment do
    raise "Must be run from the development environment" unless Rails.env.development?
    Tagging.where.not(container_id: nil).delete_all
    Container.delete_all
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

      page[:slug] = Container.normalize_slug(page_slug)
      page[:url] = url

      previous_page = page
      previous_depth = depth

      if page[:template].present?
        container = Container.create!(
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

    Container.
      find_each(&:cache_child_containers_count)

    File.open('pages-with-slugs.json', 'w+') do |f|
      f.write(output.to_json)
    end
  end

  task update_sitemap: :environment do
    #Tagging.where.not(container_id: nil).delete_all
    #Container.delete_all

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

      page[:slug] = Container.normalize_slug(page_slug)
      if url.blank?
        url = '/'
      end
      page[:url] = url

      previous_page = page
      previous_depth = depth

      if page[:template].present?
        oldpath = page[:old_path]
        container = nil
        if oldpath && container = Container.find_by(path: oldpath)
        else
          container = Container.find_or_initialize_by(path: page[:url])
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
          Tagging.where(container_id: container.id).each(&:destroy)
          container.destroy
        end

      end

      puts page[:slug]
      page
    end

    Container.
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
