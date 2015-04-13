class Components::CallsToAction
  def initialize(data)
    @data = data
  end

  def data
    @data[:widget_call_to_actions]
  end
end
