class Components::Partners
  attr_accessor :data

  def initialize(data)
    self.data = data
  end

  def data
    return [] unless @data[:partners]
    partners = @data[:partners]
    partners.map {|p| OpenStruct.new(p)}
  end
end


