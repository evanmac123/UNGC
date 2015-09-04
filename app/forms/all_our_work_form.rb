class AllOurWorkForm < SimpleDelegator
  def initialize(params, seed, search_scope = Container.issues)
    super ContainerForm.new(params, seed, sphinx_scope: search_scope)
  end
end
