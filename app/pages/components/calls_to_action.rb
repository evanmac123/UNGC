class Components::CallsToAction
  def initialize(data)
    @data = data
  end

  def data
    @data[:widget_calls_to_action]
  end
end
