class Components::CallToActions
  def initialize(data)
    @data = data
  end

  def data
    d = [@data[:widget_call_to_action]]
    if @data[:widget_call_to_action2]
      d.push(@data[:widget_call_to_action2])
    end
  end
end
