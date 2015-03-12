module UNGC
  class Container
    attr_reader :id, :size, :parent, :outlets

    def initialize(name = nil, opts = {}, &block)
      @name      = name
      @is_root   = @name ? false : true
      @parent    = opts[:parent]
      @size      = opts[:size]
      @slots_map = {}
      @slots     = []

      instance_exec &block if block_given?
    end

    def slot(key, content)
      if (existing = @slots_map[key.to_sym])
        raise "a slot already exists under the key: #{key}"
      end

      slot = Slot.new(key, content)

      @slots_map[key.to_sym] = slot
      @slots << slot
    end

    def field(key, opts = {})
      slot(key, Field.new(key, opts))
    end

    def has(num, key, opts = {}, &block)
      slot(key, Container.new({ parent_container: self }.merge(opts), &block))
    end
  end

  class Slot
    attr_reader :key, :content

    def initialize(key, content)
      @key     = key.to_sym
      @content = content
    end
  end

  class Field
    FIELD_TYPES = [
      :string,
      :integer,
      :float
    ]

    def initialize(name, opts = {})
      @type  = (opts[:type] || :string).to_sym
      @limit = opts[:limit]
      @name  = name.to_sym

      unless FIELD_TYPES.include?(@type)
        raise "unknown field type: #{@type}"
      end
    end
  end

  class Layout
    def Layout.inherited(layout)
      layout.init_design!
    end

    def self.init_design!
      @design ||= Container.new
    end

    def self.design
      @design
    end

    def self.containers
      model = ::Redesign::Container
      model.where(layout: model.layouts[layout])
    end

    def self.containers_count
      @containers_count ||= containers.count
    end

    def self.has_many_containers!
      @has_many_containers = true
    end

    def self.has_one_container!
      @has_many_containers = false
    end

    def self.has_many_containers?
      @has_many_containers ? true : false
    end

    def self.has_one_container?
      !has_many_containers?
    end

    def self.layout(val = nil)
      if val
        @layout = val.to_sym
      else
        @layout ||= to_s.demodulize.sub('Layout', '').underscore
      end
    end

    def self.label(val = nil)
      if val
        @label = val
      else
        @label
      end
    end

    def self.field(name, opts = {})
      design.field(name, opts)
    end

    def self.has(num, name, &block)
      design.has(num, name, &block)
    end
  end
end
