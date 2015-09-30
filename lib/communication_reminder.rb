module CommunicationReminder

  def self.notify_all
    CopReminder.new.notify_all
    CoeReminder.new.notify_all
  end

end
