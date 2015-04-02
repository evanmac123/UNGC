namespace :redesign do

  desc "create the basic site map"
  task :tree do
    walk page_data do |page, depth|
      title = page[:title]
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
      last_layout = page[:title].downcase.gsub(' ', '_').underscore
      last_depth = depth

      puts stack.join ","
    end
  end

  private

  def walk(pages, depth = 0, &block)
    pages.map do |page|
      value = block.call(page, depth)
      child_values = if page.has_key? :children
        walk page[:children], depth+1, &block
      else
        []
      end
      [value, child_values]
    end
  end

  def tree(pages, parent_node)
    pages.map do |page|
      node = Node.new
      node.title = page[:title]
      node.depth = parent_node.depth + 1
      node.parent = parent_node
      if page.has_key? :children
        node.children = tree(page[:children], node)
      end
      node
    end
  end

  def page_data
    data = JSON.parse(File.read('./lib/tasks/redesign/pages.json')).deep_symbolize_keys
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
