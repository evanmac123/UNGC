module FilterMacros

  def self.included(clazz)
    clazz.extend ClassMethods
  end

  FilterInfo = Struct.new(:id, :options)

  module ClassMethods
    attr_reader :filter_infos

    def filter(id, options = {})
      @filter_infos ||= []
      @filter_infos << FilterInfo.new(id, options)
    end

  end

end
