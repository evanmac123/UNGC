class AllOurWorkForm < SimpleDelegator

  def initialize(params, seed)
    super Redesign::ContainerForm.new(params, seed, sphinx_scope: Redesign::Container.issues)
  end

end
