module CommunicationStatusUpdater

  def self.update_all
    CopStatusUpdater.update_all
    CoeStatusUpdater.update_all
  end

end
