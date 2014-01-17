class CommunicationPresenter

  def self.create(cop, contact)
    presenter_class = case
    when cop.is_grace_letter?
      GraceLetterPresenter
    when cop.is_non_business_format?
      CoePresenter
    else
      CopPresenter
    end
    presenter_class.new(cop, contact)
  end

end