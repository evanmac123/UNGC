class CommunicationPresenter

  def self.create(cop, contact)
    presenter_class = if cop.is_non_business_format?
        CoePresenter
      else
        CopPresenter
    end
    presenter_class.new(cop, contact)
  end

end