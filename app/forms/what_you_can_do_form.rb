class WhatYouCanDoForm < SimpleDelegator
  def initialize(params, seed, search_scope = Container.actions)
    super ContainerForm.new(params, seed, sphinx_scope: search_scope)
  end
end
