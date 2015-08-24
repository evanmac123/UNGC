class AllOurWorkForm < SimpleDelegator

  def initialize(params, seed)
    super ContainerForm.new(params, seed, sphinx_scope: Container.issues)
  end

end
