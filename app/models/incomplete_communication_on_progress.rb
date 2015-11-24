class IncompleteCommunicationOnProgress < CommunicationOnProgress

  def complete!
    update_attributes!(type: nil)
    CommunicationOnProgress.find(self.id)
  end

end
