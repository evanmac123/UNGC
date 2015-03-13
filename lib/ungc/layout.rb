module UNGC
  class Error < StandardError; end
  class InvalidKeyError < Error; end

  class Layout
    def self.inherited(layout)
      layout.init_root_scope!
    end

    def self.init_root_scope!
      @root_scope = Scope.new
    end

    def self.root_scope
      @root_scope
    end

    def self.field(*args, &block)
      root_scope.field(*args, &block)
    end

    def self.scope(*args, &block)
      root_scope.scope(*args, &block)
    end

    def self.label(val = nil)
      val ? @label = val : @label
    end

    def self.layout(val = nil)
      val ? @layout = val.to_sym : @layout
    end

    def self.has_one_container!
      @max_containers = 1
    end

    def self.max_containers
      @max_containers ||= Infinity
    end

    def self.has_many_containers?
      max_containers != 1
    end

    def self.containers
      model = ::Redesign::Container
      model.where(layout: model.layouts[layout])
    end

    def self.containers_count
      containers.count
    end

    def initialize(data)
      @root_scope = self.class.root_scope
    end
  end

  class Scope
    attr_reader :slots, :key

    def initialize(key = nil, opts = {}, &block)
      @key   = key
      @opts  = opts
      @slots = {}

      if block_given?
        instance_exec(&block)
      end
    end

    def root?
      !@key
    end

    def scope(key, opts = {}, &block)
      @slots[key] = Scope.new(key, { parent: self }.merge(opts), &block)
    end

    def field(key, opts = {})
      @slots[key] = Field.new(key, { scope: self }.merge(opts))
    end
  end

  class Field
    def initialize(key, opts = {})
      @type = Type.lookup(opts[:type])
    end
  end

  class Type
    def Type.registry
      @registry ||= {}
    end

    def Type.lookup(key)
      if (found = registry[key.to_sym])
        found
      else
        raise "unknown type: #{key.to_sym}"
      end
    end

    def Type.register(key, &block)
      if (exists = registry[key.to_sym])
        raise "type already registered: #{key.to_sym}"
      else
        registry[key.to_sym] = Type.new(key, &block)
      end
    end

    def initialize(key, &block)
      @key = key.to_sym
      instance_exec(&block) if block_given?
    end

    def cast(&block)
      @cast = block
    end

    def bad!(msg)
      raise UNGC::InvalidKeyError, msg
    end

    def apply(raw)
      @cast ? @cast.(raw) : raw
    end

    register :string do
      cast do |raw|
        raw.blank? ? nil : raw.to_s
      end
    end

    # TODO: Enforce HREF scheme once decided on
    register :href do
      cast do |raw|
        raw.blank? ? nil : raw.to_s
      end
    end

    # TODO: Enforce URL scheme once implemented
    register :image_url do
      cast do |raw|
        raw.blank? ? nil : raw.to_s
      end
    end

    register :enum

    register :boolean do
      cast do |raw|
        case raw.to_s
        when /t|true|yes|1/i then true
        when /f|false|no|0/i then false
        else nil
        end
      end
    end
  end
end
