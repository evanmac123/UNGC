class WhatYouCanDoForm < SimpleDelegator

  def initialize(params, seed)
    super ContainerForm.new(params, seed, sphinx_scope: Redesign::Container.actions)
  end

end
