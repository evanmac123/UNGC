class WhatYouCanDoForm < SimpleDelegator

  def initialize(params, seed)
    super ContainerForm.new(params, seed, sphinx_scope: Container.actions)
  end

end
