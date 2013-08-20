class InvoiceReminder
  def initialize
    @logger = Logger.new(File.join(Rails.root, 'log', 'invoice_reminder.log'))
  end

  def deliver_all
    @organizations = Organization.companies_and_smes.ready_for_invoice

    @organizations.each do |organization|
      begin
        if organization.pledge_amount.to_i > 0
          log "Emailing organization #{org.id}:#{org.name} with foundation invoice"
          p mailer = OrganizationMailer.foundation_invoice(organization)
          mailer.deliver
        else
          log "Emailing organization #{org.id}:#{org.name} with foundation reminder"
          p mailer = OrganizationMailer.foundation_reminder(organization)
          mailer.deliver
        end
      rescue
        log :error, "Could not send email: #{$!}"
      end
    end
  end

  private
    def log (method="info", string)
      @logger.send method.to_sym, "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} : #{string}"
    end
end
