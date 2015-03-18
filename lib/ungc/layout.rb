module UNGC
  class Error < StandardError; end
  class InvalidFieldError < Error; end

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
      @max_containers ||= Float::INFINITY
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

    attr_reader :data, :errors

    def initialize(attrs = {})
      @scope  = self.class.root_scope
      @errors = []

      load(attrs)
    end

    def load(attrs)
      @attrs = attrs
      @data  = {}
      @errors.clear

      accumulate_scope(@scope, @data, @attrs)

      self
    end

    def valid?
      errors.empty?
    end

    def as_json(*args)
      @data
    end

    # TODO: It would be great to pair on this code and find a way to simplify it
    # and ideally remove all or most of the recursion. (CKN)
    private

    def add_error(path, detail)
      errors << {
        code:   :invalid,
        path:   path,
        detail: detail
      }
    end

    def accumulate_scope(scope, output, source, opts = {})
      scope.slots.values.each do |slot|
        if slot.is_a?(UNGC::Field)
          extract_field(slot, output, source, opts)
        else
          extract_container(slot, output, source, opts)
        end
      end

      output
    end

    def extract_pair(slot, source, opts = {})
      key = slot.key.to_sym
      val = source ? source[key.to_s] || source[key] : nil
      [key, val]
    end

    def extract_container(container, output, source, opts = {})
      key, value = *extract_pair(container, source, opts)

      if container.array?
        context = []
        value ||= []
      else
        context = {}
        value ||= {}
      end

      validate_container_value(container, value)

      if context.is_a?(Array)
        value.each_with_index { |v, i|
          context << accumulate_scope(container, {}, v, i: i)
        }

        validate_array_container_value(container, value)
      elsif value
        accumulate_scope(container, context, value)
      end

      output[key] = context
    end

    def extract_field(field, output, source, opts = {})
      key, raw    = *extract_pair(field, source, opts)
      value       = field.load(raw)
      output[key] = value
    rescue UNGC::InvalidFieldError => e
      path = field.path.sub('[]', "[#{opts[:i]}]")
      add_error(path, e.message)
    end

    def validate_container_value(container, value)
      if container.required? && (value.blank? || value.empty?)
        add_error(path, "must be provided")
      end
    end

    def validate_array_container_value(container, value)
      path  = container.path
      max   = container.opts[:max]
      min   = container.opts[:min]
      fixed = container.opts[:size]
      fixed ||= max if max == min

      if fixed && (value.size != fixed)
        add_error(path, "must have exactly #{fixed} item#{fixed == 1 ? '' : 's'}")
      end

      if max && (value.size > max)
        add_error(path, "must have no more than #{max} item#{max == 1 ? '' : 's'}")
      end

      if min && (value.size < min)
        add_error(path, "must have at least #{min} item#{min == 1 ? '' : 's'}")
      end
    end
  end

  class Scope
    attr_reader :slots, :key, :path, :opts

    def initialize(key = nil, opts = {}, &block)
      @key   = key
      @opts  = opts
      @slots = {}

      if block_given?
        instance_exec(&block)
      end
    end

    def parent
      @opts[:parent]
    end

    def path
      if @key
        parent && parent.path ? "#{parent.path}.#{@key}" : @key.to_s
      else
        nil
      end
    end

    def array?
      @opts[:array] ? true : false
    end

    def required?
      @opts[:required] ? true : false
    end

    def scope(key, opts = {}, &block)
      @slots[key] = Scope.new(key, { parent: self }.merge(opts), &block)
    end

    def field(key, opts = {})
      @slots[key] = Field.new(key, { scope: self }.merge(opts))
    end
  end

  class Field
    attr_reader :key, :opts, :type

    def initialize(key, opts = {})
      @key  = key.to_sym
      @type = Type.lookup(opts[:type])
      @opts = opts
    end

    def scope
      @opts[:scope]
    end

    def path
      mine = scope.array? ? "[].#{@key}" : @key.to_s

      if (base = scope.path)
        "#{base}.#{mine}"
      else
        mine
      end
    end

    def required?
      @opts[:required] ? true : false
    end

    def load(raw)
      @type.cast(raw, @opts)
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

    def validate(val, opts = {})
      if !opts[:required] && val.blank?
        return
      end

      if opts[:required] && (val != false && val.blank?)
        bad! "must be provided"
      end

      if opts[:limit] && val.respond_to?(:size) && val.size > opts[:limit]
        bad! "can not exceed #{opts[:limit]} character#{opts[:limit] == 1 ? '' : 's'}"
      end

      if opts[:enum] && !opts[:enum].include?(val)
        bad! "must be in the list: #{opts[:enum].join(', ')}"
      end
    end

    def cast(raw = nil, opts = {}, &block)
      if block_given?
        @cast = block
      else
        val = @cast ? @cast.(raw, opts) : raw
        validate(val, opts)
        val
      end
    end

    def bad!(msg)
      raise UNGC::InvalidFieldError, msg
    end

    register :string do
      cast do |raw, opts|
        raw.blank? ? nil : raw.to_s.strip
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
