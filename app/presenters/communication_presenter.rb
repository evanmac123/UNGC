class CommunicationPresenter

  def self.create(cop, contact)
    if cop.is_grace_letter?
      GraceLetterPresenter.new(cop, contact)
    else
      CopPresenter.new(cop, contact)
    end
  end

end