class Cop::Presenter
  attr_reader :cop

  def initialize(cop)
    @cop = cop
  end

  def show_admin_partial
    if cop.evaluated_for_differentiation?
      "/shared/cops/show_#{cop.differentiation}_style"
    else
      partial
    end
  end

  def show_partial
    if cop.evaluated_for_differentiation?
      "/shared/cops/show_differentiation_style_public"
    else
      partial
    end
  end

  def results_partial
    return unless cop.evaluated_for_differentiation?

    # Basic COP template has its own partial to display text responses
    if cop.is_basic?
      '/shared/cops/show_basic_style'
    else
      '/shared/cops/show_differentiation_style'
    end
  end

  private
    def partial
      if cop.is_grace_letter?
        '/shared/cops/show_grace_style'
      elsif cop.is_basic?
        '/shared/cops/show_basic_style'
      elsif cop.is_non_business_format?
        '/shared/cops/show_non_business_style'
      elsif cop.is_new_format?
        '/shared/cops/show_new_style'
      elsif cop.is_legacy_format?
        '/shared/cops/show_legacy_style'
      end
    end

end
